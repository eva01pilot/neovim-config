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


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- no mason
-- require('lspconfig').lua_ls.setup {
--     on_attach = on_attach,
--     capabilities = capabilities,
--     Lua = {
--       workspace = { checkThirdParty = false },
--       telemetry = { enable = false },
--     },
-- }

-- mason
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

    -- another example
    -- ["omnisharp"] = function()
    --     require('lspconfig').omnisharp.setup {
    --         filetypes = { "cs", "vb" },
    --         root_dir = require('lspconfig').util.root_pattern("*.csproj", "*.sln"),
    --         on_attach = on_attach,
    --         capabilities = capabilities,
    --         enable_roslyn_analyzers = true,
    --         analyze_open_documents_only = true,
    --         enable_import_completion = true,
    --     }
    -- end,
})


local lspconfig = require('lspconfig')
local mason_registry = require('mason-registry')
local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
lspconfig.ts_ls.setup {
  on_attach = on_attach,
  init_options = {
    maxTsServerMemory = 4096  -- Allocate 4GB, adjust based on your system's capacity
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "none"
      }
    }
  },
  handlers = {
    ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
      if result.uri:match("node_modules") then return end
      vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
    end,
  },
  init_options = {
	disableAutomaticTypingAcquisition = true,
    plugins = {
      {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}
-- No need to set `hybridMode` to `true` as it's the default value
lspconfig.volar.setup {
  on_attach = on_attach,
}
