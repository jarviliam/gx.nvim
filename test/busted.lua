vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Setup lazy.nvim
require("lazy.minit").busted({
  spec = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-treesitter/nvim-treesitter",
    build = function()
        require("nvim-treesitter.install").update({ with_sync = true })()
    end,
      opts = {
        ensure_installed = {
          "go",
          "terraform",
        },
        auto_install = true,
        sync_install = true,
      },
    },
  },
})
