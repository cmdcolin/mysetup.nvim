vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = 'a'
vim.o.cmdheight = 0
-- Scheduled to avoid increasing startup-time
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)
vim.o.breakindent = true
vim.o.undofile = true
-- CursorHold delay and swap file write interval
vim.o.updatetime = 250
-- Mapped sequence wait time (affects which-key popup delay)
vim.o.timeoutlen = 300
vim.o.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}
vim.o.swapfile = false
-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true
-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'
-- Decrease update time
vim.o.updatetime = 250
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'
-- Show which line your cursor is on
vim.o.cursorline = true
-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 10
-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
  desc = 'Open diagnostic [Q]uickfix list',
})
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },
  underline = {
    severity = vim.diagnostic.severity.ERROR,
  },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
  },
}

vim.lsp.config('tsgo', {
  cmd = { 'tsgo', '--lsp', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim', 'Snacks' } },
      workspace = { checkThirdParty = false },
    },
  },
})

vim.pack.add {
  'https://github.com/webhooked/kanso.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.x') },
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/j-hui/fidget.nvim',
  'https://github.com/folke/persistence.nvim',
  'https://github.com/max397574/better-escape.nvim',
  'https://github.com/m4xshen/hardtime.nvim',
  'https://github.com/echasnovski/mini.ai',
  'https://github.com/echasnovski/mini.surround',
  'https://github.com/stevearc/oil.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/folke/todo-comments.nvim',
  'https://github.com/folke/trouble.nvim',
  'https://github.com/rachartier/tiny-code-action.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
  'https://github.com/catgoose/nvim-colorizer.lua',
  'https://github.com/tronikelis/ts-autotag.nvim',
  'https://github.com/folke/flash.nvim',
}

-- On first run vim.pack.add installs plugins after startup; skip setup until restart
if not vim.uv.fs_stat(vim.fn.stdpath 'config' .. '/nvim-pack-lock.json') then
  vim.notify('First run: plugins are being installed, restart when done', vim.log.levels.WARN)
  return
end

vim.cmd 'colorscheme kanso'

-- Workaround: kanso NonText is too dim on SnacksPickerListCursorLine bg
vim.api.nvim_set_hl(0, 'SnacksPickerDir', { link = 'Comment' })

require('better_escape').setup()
require('mini.ai').setup()
require('mini.surround').setup()
require('colorizer').setup()
require('ts-autotag').setup()
require('flash').setup { frecency = true }
require('oil').setup {
  view_options = { show_hidden = false },
  win_options = { signcolumn = 'yes:2' },
}
require('fidget').setup()
require('persistence').setup()
require('todo-comments').setup { signs = false }
require('trouble').setup()
require('tiny-code-action').setup { picker = 'snacks' }

if vim.env.HARDMODE == 'true' then
  require('hardtime').setup()
end

require('blink.cmp').setup {
  keymap = { preset = 'super-tab' },
  completion = {
    ghost_text = { enabled = true },
    accept = { auto_brackets = { enabled = false } },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    list = { selection = { preselect = true, auto_insert = true } },
  },
  sources = { default = { 'lsp', 'path', 'snippets' } },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
  signature = { enabled = true },
}

vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<leader>rn', function()
      vim.lsp.buf.rename()
      vim.cmd 'silent! wa'
    end, { buffer = event.buf, desc = 'LSP: [R]e[n]ame' })
    vim.keymap.set('n', '<leader>ca', function()
      require('tiny-code-action').code_action()
    end, { buffer = event.buf, silent = true, desc = 'LSP: Code Action' })
  end,
})

vim.lsp.enable { 'lua_ls', 'tsgo', 'ruff', 'bashls', 'clangd' }

require('conform').setup {
  notify_on_error = false,
  format_on_save = { timeout_ms = 6000, lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescript = { 'prettier' },
    typescriptreact = { 'prettier' },
    json = { 'prettier' },
    markdown = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
  },
}

require('nvim-treesitter').setup {
  ensure_installed = {
    'bash', 'c', 'diff', 'html', 'lua', 'luadoc',
    'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',
  },
  auto_install = true,
  highlight = { enable = true },
  indent = { enable = false },
}

require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch' },
  },
}

require('snacks').setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.picker.recent({ filter = { cwd = true } })' },
        { icon = ' ', key = 'q', desc = 'Quit',         action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { pane = 1,          section = 'keys',         gap = 1,    padding = 1 },
      { pane = 2,          section = 'recent_files', icon = ' ', title = 'Recent Files', limit = 8, indent = 2, padding = 1, cwd = true },
    },
  },
  explorer = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  scroll = { enabled = true },
  picker = { enabled = true, formatters = { file = { filename_first = true } } },
  quickfile = { enabled = true },
  scope = { enabled = true },
  statuscolumn = { enabled = true },
  styles = { notification = { wo = { wrap = true } } },
}

vim.schedule(function()
  _G.dd = function(...)
    Snacks.debug.inspect(...)
  end
  _G.bt = function()
    Snacks.debug.backtrace()
  end
  vim.print = _G.dd

  Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
  Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
  Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
  Snacks.toggle.diagnostics():map '<leader>ud'
  Snacks.toggle.line_number():map '<leader>ul'
  Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map '<leader>uc'
  Snacks.toggle.treesitter():map '<leader>uT'
  Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map '<leader>ub'
  Snacks.toggle.inlay_hints():map '<leader>uh'
  Snacks.toggle.indent():map '<leader>ug'
  Snacks.toggle.dim():map '<leader>uD'
end)

vim.keymap.set('n', '<leader><space>', function() Snacks.picker.files() end, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Grep' })
vim.keymap.set('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' })
vim.keymap.set('n', 'gD', function() Snacks.picker.lsp_declarations() end, { desc = 'Goto Declaration' })
vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, { nowait = true, desc = 'References' })
vim.keymap.set({ 'n', 'v' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse' })
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash' })
vim.keymap.set('n', '<leader>?', function() require('which-key').show { global = false } end,
  { desc = 'Buffer Local Keymaps (which-key)' })
vim.keymap.set('n', '<leader>ll', function() vim.pack.update() end, { desc = 'Update plugins' })
vim.keymap.set('n', '<leader>lc', function() vim.pack.clean() end, { desc = 'Clean plugins' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('n', '<C-l>', ':w<CR>', { desc = 'Save file in normal mode' })
vim.keymap.set('i', '<C-l>', '<C-o>:w<CR><Esc>', { desc = 'Save file and exit insert mode' })
vim.keymap.set('n', '<c-w>d', vim.diagnostic.open_float, { desc = 'Open diagnostics' })

vim.keymap.set('n', '<leader>pc', function()
  vim.fn.setreg('+', vim.fn.expand '%')
end, { silent = true, desc = 'Copy path to clipboard' })

vim.keymap.set('n', 'cll', function()
  local function_name = 'anonymous'
  local node = vim.treesitter.get_node()
  while node do
    local t = node:type()
    if t == 'function_declaration' or t == 'arrow_function' or t == 'function_expression' or t == 'method_definition' then
      for child in node:iter_children() do
        if child:type() == 'identifier' or child:type() == 'property_identifier' then
          function_name = vim.treesitter.get_node_text(child, 0)
          break
        end
      end
      break
    end
    node = node:parent()
  end
  vim.api.nvim_put({ string.format('console.log("%s")', function_name) }, 'l', true, true)
end, { silent = true, desc = 'Insert console.log with function name' })
