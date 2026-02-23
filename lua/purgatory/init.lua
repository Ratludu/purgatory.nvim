local helpers = require("purgatory.helpers")
local config = require("purgatory.config")
local M = {}
M.opts = {}



M.setup = function(user_opts)
  M.opts = vim.tbl_extend("force", config.defaults, user_opts or {})
  if M.opts.keymaps.open then
    vim.keymap.set("n", M.opts.keymaps.open, function()
      M.open()
    end, { desc = "Open Purgatory", noremap = true, silent = true })
  end
end

function M.open()
  local filepath = helpers.get_filepath()

  local lines = {}
  if vim.fn.filereadable(filepath) == 1 then
    lines = vim.fn.readfile(filepath)
  end

  local existing_buf = vim.fn.bufnr(filepath)
  if existing_buf ~= -1 then
    local existing_win = vim.fn.bufwinid(existing_buf)
    if existing_win ~= -1 then
      vim.api.nvim_set_current_win(existing_win)
      return
    end
    vim.api.nvim_buf_delete(existing_buf, { force = true })
  end

  local buf, win = helpers.open_floating_window(M.opts)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].filetype = "text"
  vim.bo[buf].modified = false
  vim.bo[buf].buftype = "acwrite"
  vim.api.nvim_buf_set_name(buf, filepath)

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function()
      local updated = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.fn.writefile(updated, filepath)
      vim.bo[buf].modified = false
      vim.notify("Purgatory saved!", vim.log.levels.INFO)
    end,
  })

  local kopts = { buffer = buf, noremap = true, silent = true }

  for _, key in ipairs(M.opts.keymaps.close) do
    vim.keymap.set("n", key, "<cmd>bd!<cr>", kopts)
  end
end

return M
