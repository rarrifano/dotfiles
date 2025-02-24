local function bootstrap_pckr() local pckr_path = vim.fn.stdpath('data') ..
  '/pckr/pckr.nvim'

  if not (vim.uv or vim.loop).fs_stat(pckr_path) then vim.fn.system({ 'git',
    'clone', '--filter=blob:none', 'https://github.com/lewis6991/pckr.nvim',
    pckr_path }) end

  vim.opt.rtp:prepend(pckr_path) end

bootstrap_pckr()

require('pckr').add{
  'ellisonleao/gruvbox.nvim';
  'tpope/vim-fugitive';
  'neovim/nvim-lspconfig';
  'hrsh7th/nvim-cmp';
  'hrsh7th/cmp-nvim-lsp';
  'williamboman/mason.nvim';
  'williamboman/mason-lspconfig.nvim';

  { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' };

  { 'nvim-telescope/telescope.nvim', tag = '0.1.8', requires = {
    {'nvim-lua/plenary.nvim'} } };

  { "ThePrimeagen/harpoon", branch = "harpoon2", requires = {
    {"nvim-lua/plenary.nvim"} } };
}
