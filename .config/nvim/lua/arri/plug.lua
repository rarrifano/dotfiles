local function bootstrap_pckr() local pckr_path = vim.fn.stdpath('data') ..
  '/pckr/pckr.nvim'

  if not (vim.uv or vim.loop).fs_stat(pckr_path) then vim.fn.system({ 'git',
    'clone', '--filter=blob:none', 'https://github.com/lewis6991/pckr.nvim',
    pckr_path }) end

  vim.opt.rtp:prepend(pckr_path) end

bootstrap_pckr()

require('pckr').add{
  -- Syntax Highlight
  'sainnhe/gruvbox-material';
  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };

  -- LSP
  'neovim/nvim-lspconfig';
  'williamboman/mason.nvim';
  'williamboman/mason-lspconfig.nvim';

  -- Autocomplete
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-nvim-lsp';
  'hrsh7th/cmp-buffer';
  'hrsh7th/cmp-path';

  -- Pickers
  { 'nvim-telescope/telescope.nvim', requires = {
    {'nvim-lua/plenary.nvim'} } };
  { "ThePrimeagen/harpoon", branch = "harpoon2", requires = {
    {"nvim-lua/plenary.nvim"} } };
}
