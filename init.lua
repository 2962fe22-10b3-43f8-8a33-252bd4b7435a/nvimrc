local key = vim.keymap.set
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.g.netrw_banner = 0
vim.opt.path:append("**")
vim.opt.wildignore:append {".venv/*", ".git/*"}
vim.opt.clipboard = 'unnamedplus'
vim.opt.tabstop = 4
vim.opt.softtabstop = -1 -- link to 'ts
vim.opt.shiftwidth = 0 -- link to 'ts
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true
vim.cmd 'language en_US'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.colorcolumn = '80'
vim.opt.mouse = ''
vim.cmd 'set mousescroll=ver:8,hor:4'
vim.opt.showmode = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.autoread = true
vim.opt.undofile = true
-- :echo stdpath('config')
vim.opt.undodir = (os.getenv 'HOME' or os.getenv 'HOMEPATH') .. '/.vim/undodir'
vim.opt.wildignorecase = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'no'
vim.opt.list = true
vim.opt.listchars = { tab = '| ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.hlsearch = true
vim.opt.scrolloff = 8
vim.cmd 'filetype plugin indent on | syntax on'
vim.opt.makeprg = 'make build'
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- vim.o.foldenable = false
if vim.fn.executable 'rg' then
  vim.opt.grepprg = 'rg --vimgrep --no-heading --smart-case'
  vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m'
end
local grep = function() vim.ui.input({ prompt = 'grep>' },
  function(c) if c then vim.cmd('silent grep '..c..' | copen 6')
end end) end
local scratch = function()
  vim.ui.input({prompt='sh>'}, function(c)
    if c and c~="" then
      vim.cmd "noswapfile vnew"
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.systemlist(c))
end end) end

vim.filetype.add {
  extension = {
    frag = 'glsl',
    vert = 'glsl',
    comp = 'glsl',
    ua = 'uiua',
    ixx = 'cpp',
    cppm = 'cpp',
    xaml = 'xml',
    axaml = 'xml',
  },
  pattern = {
    [".*/include/%w*"] = 'cpp',
  }
}

local autosave_enabled = false
local toggle_autosave = function()
  autosave_enabled = not autosave_enabled vim.cmd'w'
  vim.notify('autosave = ' .. tostring(autosave_enabled)) end
vim.api.nvim_create_autocmd('TextYankPost',
  { callback = function() vim.highlight.on_yank() end})
vim.api.nvim_create_autocmd({'InsertLeave', 'TextChanged'}, {
  callback = function ()
    if autosave_enabled
        and #vim.api.nvim_buf_get_name(0) ~= 0
        and vim.bo.buflisted
        and vim.bo.buftype ~= 'terminal' then
      vim.cmd 'lockmarks silent w' end end })

-- key('n', '<C-c>', 'ciw')
-- key('n', '<leader><leader>', '<leader>', { remap = true })
-- key({ 'n', 'v' }, 'cc', 'c', {remap=true})
-- key('n', '<C-d>', '20<C-d>')
key('i', '{<CR>', '{<CR>}<Esc>O')
key('n', '-', ':Oil<CR>')
key('n', '<C-g>', '2<C-g>')
key('n', '<C-w><C-s>', '<C-w>s<C-w>j')
key('n', '<C-w><C-v>', '<C-w>v<C-w>l')
key('n', '<Down>', ':cclose<CR>')
key('n', '<Left>', ':cp<CR>')
key('n', '<Right>', ':cn<CR>')
key('n', '<Up>', ':copen 6<CR>')
key('n', '<Esc>', ':nohl<CR>')
key('n', '<leader>`', ':bel 16sp +term<CR>a')
key('n', '<leader>b', ':ls<CR>:b ')
key('n', '<leader>f', grep)
key('n', '<leader>j', ':silent !jj new<CR>')
key('n', '<leader>m', ':silent make<CR>')
key('n', '<leader>n', ':e $MYVIMRC<CR>')
key('n', '<leader>p', toggle_autosave)
key('n', '<leader>s', scratch)
key('n', '<leader>w', ':set nu! rnu!<CR>')
key('n', '\\', ':cgetbuffer | bd | copen 6<CR>', { desc = 'Send buf to quickfix' })
key('n', 'cd', ':cd %:p:h<CR>')
key('n', 'gy', '`[v`]')
key('t', '<Esc>', '<C-\\><C-n>')
key('v', '<C-n>', ':norm ')
key('v', 'p', '"_dP')
key( { 'i', 'n', 'v' }, '<C-s>',
  [[<Esc>:wa | if v:this_session != ""
      exe "mks!" . v:this_session
      endif<CR><CR>]],
  { desc = '[S]ave all files and session if present' })

-------- PLUGINS --------

vim.pack.add({
  { src = 'https://github.com/2962fe22-10b3-43f8-8a33-252bd4b7435a/prasiolite', version = 'dev' },
  'https://github.com/numToStr/Comment.nvim',
  -- 'https://github.com/norcalli/nvim-colorizer.lua',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/stevearc/oil.nvim',
})

vim.cmd "colorscheme prasiodark"
require('Comment').setup({})
require('nvim-treesitter.config').setup({
  ensure_installed = { 'bash', 'c', 'cpp', 'html', 'lua', 'markdown', 'vim', 'vimdoc', },
  highlight = { enable = true, disable = function(lang, buf)
    local ok, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    if ok and stat and stat.size > 102400 then return true end end }})
require('nvim-treesitter.install').compilers = { 'clang' }
require('oil').setup({
  keymaps = {
    ["g?"]    = "actions.show_help",
    ["<CR>"]  = "actions.select",
    ["<C-h>"] = { "actions.select", opts = { horizontal = true, split = "belowright" } },
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<Esc>"] = "actions.close",
    ["<C-r>"] = "actions.refresh",
    ["-"]     = "actions.parent",
    ["_"]     = "actions.open_cwd",
    ["cd"]    = "actions.cd",
    ["gs"]    = "actions.change_sort",
    ["gx"]    = "actions.open_external",
    ["g."]    = "actions.toggle_hidden",
  },
  skip_confirm_for_simple_edits = true,
  preview_split = "above",
  view_options = { show_hidden = true }})

-- vim: ts=2
