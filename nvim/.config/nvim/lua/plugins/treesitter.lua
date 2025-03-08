return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = { "python", "lua", "bash", "yaml", "json" },
    highlight = {
      enable = true,
    },
  },
}
