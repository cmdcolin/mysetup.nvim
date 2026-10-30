#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin"
mkdir -p "$BIN"
export PATH="$BIN:$PATH"

has() { command -v "$1" &>/dev/null; }

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  arm64)         ARCH="aarch64" ;;  # macOS reports arm64, normalize to aarch64
esac
case "$ARCH" in
  x86_64)        ARCH_SHORT="x64" ;;
  aarch64)       ARCH_SHORT="arm64" ;;
  *) echo "unsupported arch: $ARCH" >&2; exit 1 ;;
esac
case "$OS" in
  darwin) OS_PRETTY="macos" ;;
  *)      OS_PRETTY="$OS" ;;
esac

if ! has uv; then
  echo "installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

npm_install() {
  local pkg="$1" bin="${2:-$1}"
  if has "$bin"; then
    echo "skip: $bin already in PATH"
  else
    echo "installing $pkg..."
    npm install -g --prefix "$HOME/.local" "$pkg"
  fi
}

github_latest_tag() {
  curl -s "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
}

install_lua_ls() {
  if has lua-language-server; then
    echo "skip: lua-language-server already in PATH"
    return
  fi
  echo "installing lua-language-server..."
  local version
  version=$(github_latest_tag LuaLS/lua-language-server)
  local tmp
  tmp=$(mktemp -d)
  curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-${OS}-${ARCH_SHORT}.tar.gz" \
    | tar -xz -C "$tmp"
  local dest="$HOME/.local/lib/lua-language-server"
  mkdir -p "$dest"
  cp -r "$tmp/." "$dest/"
  ln -sf "$dest/bin/lua-language-server" "$BIN/lua-language-server"
  rm -rf "$tmp"
}

install_tree_sitter() {
  if has tree-sitter; then
    echo "skip: tree-sitter already in PATH"
    return
  fi
  echo "installing tree-sitter..."
  curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-${OS_PRETTY}-${ARCH_SHORT}.gz" \
    | gunzip >"$BIN/tree-sitter"
  chmod +x "$BIN/tree-sitter"
}

install_stylua() {
  if has stylua; then
    echo "skip: stylua already in PATH"
    return
  fi
  echo "installing stylua..."
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/JohnnyMorganz/StyLua/releases/latest/download/stylua-${OS_PRETTY}-${ARCH}.zip" \
    -o "$tmp/stylua.zip"
  unzip -q "$tmp/stylua.zip" -d "$tmp"
  install -m 755 "$tmp/stylua" "$BIN/"
  rm -rf "$tmp"
}

uv_tool_install() {
  local pkg="$1" bin="${2:-$1}"
  if has "$bin"; then
    echo "skip: $bin already in PATH"
  else
    echo "installing $pkg..."
    uv tool install --force "$pkg"
  fi
}

install_lua_ls
install_tree_sitter
install_stylua
npm_install @typescript/native-preview tsgo
npm_install prettier
npm_install oxfmt
uv_tool_install ruff

echo ""
echo "done — make sure $BIN is in your PATH"
