local M = {}

M.defaults = {
  filepath = vim.fn.expand("./todo.txt"),
  width_percent = 0.8,
  height_percent = 0.8,
  border = "rounded",
  keymaps = {
    close = { "<Esc>", "q" },
    save_and_close = "<leader>w",
  },
}

return M
