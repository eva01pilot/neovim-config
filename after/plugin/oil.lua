require("oil").setup({
	default_file_explorer = true,
	columns = {
		"icon",
		-- "permissions",
		-- "size",
		-- "mtime",
	},
})
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })
