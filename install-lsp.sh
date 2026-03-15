#!/usr/bin/env bash
set -euo pipefail

BIN="$HOME/.local/bin"
mkdir -p "$BIN"

has() { command -v "$1" &>/dev/null; }

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
  curl -sL "https://github.com/LuaLS/lua-language-server/releases/download/${version}/lua-language-server-${version}-linux-x64.tar.gz" \
    | tar -xz -C "$tmp"
  local dest="$HOME/.local/lib/lua-language-server"
  mkdir -p "$dest"
  cp -r "$tmp/." "$dest/"
  ln -sf "$dest/bin/lua-language-server" "$BIN/lua-language-server"
  rm -rf "$tmp"
}

install_shellcheck() {
  if has shellcheck; then
    echo "skip: shellcheck already in PATH"
    return
  fi
  echo "installing shellcheck..."
  local version
  version=$(github_latest_tag koalaman/shellcheck)
  local tmp
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/${version}/shellcheck-${version}.linux.x86_64.tar.xz" \
    -o "$tmp/shellcheck.tar.xz"
  tar -xJf "$tmp/shellcheck.tar.xz" -C "$tmp"
  cp "$tmp/shellcheck-${version}/shellcheck" "$BIN/"
  rm -rf "$tmp"
}

install_clangd() {
  if has clangd; then
    echo "skip: clangd already in PATH"
    return
  fi
  echo "installing clangd..."
  local version
  version=$(github_latest_tag llvm/llvm-project | sed 's/llvmorg-//')
  local tmp
  tmp=$(mktemp -d)
  curl -sL "https://github.com/llvm/llvm-project/releases/download/llvmorg-${version}/clangd-linux-${version}.zip" \
    -o "$tmp/clangd.zip"
  unzip -q "$tmp/clangd.zip" -d "$tmp"
  cp "$tmp/clangd_${version}/bin/clangd" "$BIN/"
  rm -rf "$tmp"
}

install_lua_ls
install_shellcheck
install_clangd
npm_install typescript
npm_install typescript-language-server
npm_install bash-language-server bash-language-server

echo ""
echo "done — make sure $BIN is in your PATH"
