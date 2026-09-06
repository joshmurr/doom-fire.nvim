vim.api.nvim_create_user_command("Fire", function()
	require("doom-fire").openFloat()
end, { desc = "Start the fire" })
