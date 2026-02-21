local M = {}
local config = require("purgatory.config")

M.opts = {}


local function check_buffer_exists(filepath)
  local existing_buf = vim.fn.bufnr(filepath)
  if existing_buf ~= -1 then
    local existing_win = vim.fn.bufwinid(existing_buf)
    if existing_win ~= -1 then
      vim.api.nvim_set_current_win(existing_win)
      return
    end
    vim.api.nvim_buf_delete(existing_buf, { force = true })
  end
end

local function open_floating_window(opts)
  local opts = opts or {}
  local width = vim.o.columns
  local height = vim.o.lines

  local win_width = opts.width or math.floor(width * (opts.width_percent or 0.5))
  local win_height = opts.height or math.floor(height * (opts.height_percent or 0.5))

  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)

  local win_opts = {
    relative = "editor", -- relative to the whole editor
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",  -- no line numbers, sign column, etc.
    border = "rounded", -- none | single | double | rounded | solid | shadow
    title = "purgatory",
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return buf, win
end

M.setup = function(user_opts)
  M.opts = vim.tbl_extend("force", config.defaults, user_opts or {})

  if M.opts.keymaps.open then
    vim.keymap.set("n", M.opts.keymaps.open, function()
      M.open()
    end, { desc = "Open Purgatory", noremap = true, silent = true })
  end
end

function M.open(filepath)
  filepath = filepath or M.opts.filepath
  filepath = vim.fn.expand(filepath)

  check_buffer_exists(filepath)

  local lines = {}
  if vim.fn.filereadable(filepath) == 1 then
    lines = vim.fn.readfile(filepath)
  end

  buf, win = open_floating_window(M.opts)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  vim.bo[buf].filetype = "text"
  vim.bo[buf].modified = false
  vim.api.nvim_buf_set_name(buf, filepath)
  vim.bo[buf].buftype = "acwrite"

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
