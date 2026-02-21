if vim.g.loaded_purgatory then return end
vim.g.loaded_purgatory = true

vim.api.nvim_create_user_command("Purgatory", function(args)
  local filepath = args.args ~= "" and args.args or nil
  require("purgatory").open(filepath)
end, {
  nargs = "?", -- optional filepath argument
  desc = "Open todo list in floating window",
})
