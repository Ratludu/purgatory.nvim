local M = {}

--- returns the git repo friendly name
--- and the git tree hash of the repo so that
--- there should not be any collisions.
---@return nil|string, nil|string
function M.get_git_repo_name()
  local result = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end

  local git_tree = vim.fn.system("git rev-list --max-parents=0 HEAD 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return vim.fn.fnamemodify(result:gsub("\n", ""), ":t"), vim.fn.fnamemodify(git_tree:gsub("\n", ""), ":t")
end

--- returns the filepath of the repo
---@return string
function M.get_filepath()
  local _, git_tree = M.get_git_repo_name()
  if git_tree then
    filepath = vim.fn.stdpath("data") .. "/purgatory/" .. git_tree .. ".txt"
  else
    filepath = vim.fn.stdpath("data") .. "/purgatory/default.txt"
  end
  vim.fn.mkdir(vim.fn.fnamemodify(filepath, ":h"), "p")
  vim.fn.expand(filepath)
  return filepath
end

---@param filepath string
function M.check_buffer_exists(filepath)
  if filepath ~= nil then
    return
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
end

function M.open_floating_window(opts)
  local opts = opts or {}
  local width = vim.o.columns
  local height = vim.o.lines

  local win_width = opts.width or math.floor(width * (opts.width_percent or 0.5))
  local win_height = opts.height or math.floor(height * (opts.height_percent or 0.5))

  local row = math.floor((height - win_height) / 2)
  local col = math.floor((width - win_width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local title_extension, _ = M.get_git_repo_name()

  local title = " purgatory - no repo "
  if title_extension ~= nil then
    title = " purgatory - " .. title_extension .. " "
  end

  local win_opts = {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return buf, win
end

return M
