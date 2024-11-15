local on_attach = function(_, bufnr)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = bufnr })
	end


	local cmp = require('cmp')
	bufmap('<C-Space>', cmp.mapping.complete())

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>a', vim.lsp.buf.code_action)
	bufmap("<leader>f", function() vim.lsp.buf.format() end)
	bufmap("gl", function() vim.diagnostic.open_float() end, opts)

	bufmap('gd', vim.lsp.buf.definition)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	bufmap('gr', require('telescope.builtin').lsp_references)
	bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
	bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

	bufmap('K', vim.lsp.buf.hover)

	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, {})
end

local on_attach_prettier = function(_, bufnr)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = bufnr })
	end


	local cmp = require('cmp')
	bufmap('<C-Space>', cmp.mapping.complete())

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>a', vim.lsp.buf.code_action)
	bufmap("<leader>f", function() vim.cmd('Prettier') end)
	bufmap("gl", function() vim.diagnostic.open_float() end, opts)

	bufmap('gd', vim.lsp.buf.definition)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	bufmap('gr', require('telescope.builtin').lsp_references)
	bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
	bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

	bufmap('K', vim.lsp.buf.hover)

	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, {})
end

local on_attach_tstools = function(_, bufnr)
	local bufmap = function(keys, func)
		vim.keymap.set('n', keys, func, { buffer = bufnr })
	end

	local gd = require("typescript-tools.api").go_to_source_definition

	local cmp = require('cmp')
	bufmap('<C-Space>', cmp.mapping.complete())

	bufmap('<leader>r', vim.lsp.buf.rename)
	bufmap('<leader>a', vim.lsp.buf.code_action)
	bufmap("<leader>f", function() vim.cmd('Prettier') end)
	bufmap("gl", function() vim.diagnostic.open_float() end, opts)

	bufmap('gd', gd)
	bufmap('gD', vim.lsp.buf.declaration)
	bufmap('gI', vim.lsp.buf.implementation)
	bufmap('<leader>D', vim.lsp.buf.type_definition)

	bufmap('gr', require('telescope.builtin').lsp_references)
	bufmap('<leader>s', require('telescope.builtin').lsp_document_symbols)
	bufmap('<leader>S', require('telescope.builtin').lsp_dynamic_workspace_symbols)

	bufmap('K', vim.lsp.buf.hover)

	vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
		vim.lsp.buf.format()
	end, {})
end
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

require("mason").setup()
require("mason-lspconfig").setup_handlers({

	function(server_name)
		require("lspconfig")[server_name].setup {
			on_attach = on_attach,
			capabilities = capabilities
		}
	end,

	["lua_ls"] = function()
		require('neodev').setup()
		require('lspconfig').lua_ls.setup {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				Lua = {
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			}
		}
	end
})


local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')
local mason_registry = require('mason-registry')


local installed_servers = mason_lspconfig.get_installed_servers()
for _, server in ipairs(installed_servers) do
	lspconfig[server].setup {
		on_attach = on_attach,
	}
end

require("typescript-tools").setup {
	on_attach = on_attach_tstools,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue", -- This needed to be added.
	},
	settings = {
		-- spawn additional tsserver instance to calculate diagnostics on it
		separate_diagnostic_server = true,
		-- "change"|"insert_leave" determine when the client asks the server about diagnostic
		publish_diagnostic_on = "insert_leave",
		-- array of strings("fix_all"|"add_missing_imports"|"remove_unused"|
		-- "remove_unused_imports"|"organize_imports") -- or string "all"
		-- to include all supported code actions
		-- specify commands exposed as code_actions
		-- string|nil - specify a custom path to `tsserver.js` file, if this is nil or file under path
		-- not exists then standard path resolution strategy is applied
		tsserver_path = nil,
		-- specify a list of plugins to load by tsserver, e.g., for support `styled-components`
		-- (see 💅 `styled-components` support section)
		tsserver_plugins = {
			'@vue/typescript-plugin',
		},
		-- this value is passed to: https://nodejs.org/api/cli.html#--max-old-space-sizesize-in-megabytes
		-- memory limit in megabytes or "auto"(basically no limit)
		tsserver_max_memory = 8192,
		-- described below
		-- locale of all tsserver messages, supported locales you can find here:
		-- https://github.com/microsoft/TypeScript/blob/3c221fc086be52b19801f6e8d82596d04607ede6/src/compiler/utilitiesPublic.ts#L620
		tsserver_locale = "en",
		-- mirror of VSCode's `typescript.suggest.completeFunctionCalls`
		complete_function_calls = false,
		include_completions_with_insert_text = true,
		-- CodeLens
		-- WARNING: Experimental feature also in VSCode, because it might hit performance of server.
		-- possible values: ("off"|"all"|"implementations_only"|"references_only")
		code_lens = "off",
		-- by default code lenses are displayed on all referencable values and for some of you it can
		-- be too much this option reduce count of them by removing member references from lenses
		disable_member_code_lens = true,
		-- JSXCloseTag
		-- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
		-- that maybe have a conflict if enable this feature. )
		jsx_close_tag = {
			enable = false,
			filetypes = { "javascriptreact", "typescriptreact" },
		}
	},
}
