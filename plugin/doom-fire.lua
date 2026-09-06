vim.api.nvim_create_user_command("Fire", function()
	require("doom-fire").run()
end, { desc = "Start the fire" })
