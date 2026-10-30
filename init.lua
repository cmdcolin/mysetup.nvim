vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

require('vim._core.ui2').enable { msg = { targets = 'msg' } }

vim.o.number = true
vim.o.mouse = 'a'
vim.o.cmdheight = 0
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.swapfile = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.autoread = true
vim.o.winborder = 'rounded'
vim.o.autocomplete = true
vim.o.complete = '.,w'
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'

vim.diagnostic.config {
  severity_sort = true,
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = { source = 'if_many', spacing = 2 },
}

vim.pack.add {
  'https://github.com/webhooked/kanso.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/folke/snacks.nvim',
  'https://github.com/folke/which-key.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/nvim-treesitter/nvim-treesitter',
}

vim.cmd 'colorscheme kanso'
-- kanso's NonText is too dim on SnacksPickerListCursorLine bg
vim.api.nvim_set_hl(0, 'SnacksPickerDir', { link = 'Comment' })

vim.lsp.enable { 'lua_ls', 'tsgo', 'ruff' }

local js = { 'oxfmt', 'prettier', stop_after_first = true }
require('conform').setup {
  notify_on_error = false,
  format_on_save = { timeout_ms = 6000, lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = js,
    javascriptreact = js,
    typescript = js,
    typescriptreact = js,
    astro = { 'prettier' },
    json = { 'prettier' },
    markdown = { 'prettier' },
    html = { 'prettier' },
    css = { 'prettier' },
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },
    python = { 'ruff_fix', 'ruff_format', 'ruff_organize_imports' },
  },
}

require('nvim-treesitter').install { 'bash', 'css', 'html', 'javascript', 'json', 'python', 'tsx', 'typescript' }

require('which-key').setup {
  delay = 0,
  spec = { { '<leader>s', group = '[S]earch' } },
}

require('snacks').setup {
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = ' ', key = 'r', desc = 'Recent Files', action = function() Snacks.picker.recent { filter = { cwd = true } } end },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
    sections = {
      { section = 'header' },
      { pane = 1, section = 'keys', gap = 1, padding = 1 },
      { pane = 2, section = 'recent_files', icon = ' ', title = 'Recent Files', limit = 8, indent = 2, padding = 1, cwd = true },
    },
  },
  explorer = { enabled = true },
  picker = { enabled = true, formatters = { file = { filename_first = true } } },
}

Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
Snacks.toggle.diagnostics():map '<leader>ud'

local augroup = vim.api.nvim_create_augroup('mysetup', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function() vim.hl.on_yank() end,
})
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  callback = function(ev) pcall(vim.treesitter.start, ev.buf) end,
})
vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev) vim.bo[ev.buf].complete = 'o' end,
})
-- 'autoread' alone misses files that other processes (e.g. Claude) edit while open
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI', 'TermLeave' }, {
  group = augroup,
  callback = function()
    if vim.o.buftype == '' and vim.api.nvim_buf_get_name(0) ~= '' and vim.fn.mode() ~= 'c' then
      vim.cmd 'silent! checktime'
    end
  end,
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = augroup,
  callback = function() vim.notify 'Buffer reloaded (changed on disk)' end,
})

local map = vim.keymap.set
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('i', '<Tab>', function()
  if vim.fn.pumvisible() == 0 then
    return '<Tab>'
  end
  return vim.fn.complete_info({ 'selected' }).selected == -1 and '<C-n><C-y>' or '<C-y>'
end, { expr = true, desc = 'Accept completion' })
map('n', '<leader><space>', function() Snacks.picker.files() end, { desc = 'Find Files' })
map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Grep' })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
map('n', 'gd', function() Snacks.picker.lsp_definitions() end, { desc = 'Goto Definition' })
map('n', 'gD', function() Snacks.picker.lsp_declarations() end, { desc = 'Goto Declaration' })
map('n', 'grr', function() Snacks.picker.lsp_references() end, { desc = 'References' })
map('n', '-', function() Snacks.explorer() end, { desc = 'File explorer' })
map({ 'n', 'v' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse' })
map('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
map('n', '<leader>ll', function() vim.pack.update() end, { desc = 'Update plugins' })
map('n', '<leader>lc', function()
  local stale = vim.iter(vim.pack.get()):filter(function(p) return not p.active end):map(function(p) return p.spec.name end):totable()
  if #stale == 0 then
    return vim.notify 'No stale plugins'
  end
  vim.pack.del(stale)
end, { desc = 'Clean plugins' })
map('n', '<C-l>', '<cmd>w<CR>', { desc = 'Save' })
map('i', '<C-l>', '<Esc><cmd>w<CR>', { desc = 'Save and exit insert mode' })
map('n', '<leader>pc', function() vim.fn.setreg('+', vim.fn.expand '%') end, { desc = 'Copy path to clipboard' })
