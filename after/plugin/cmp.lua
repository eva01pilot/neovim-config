local cmp = require('cmp')

cmp.setup {
	mapping = cmp.mapping.preset.insert {
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-d>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete {},
		['<CR>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { 'i', 's' }),
	},
	-- To see more information :h cmp-config.sources
	sources = cmp.config.sources({
		{
			name = 'nvim_lsp',
			---@param entry cmp.Entry
			---@param ctx cmp.Context
			entry_filter = function(entry, ctx)
				-- Check if the buffer type is 'vue'
				if ctx.filetype ~= 'vue' then
					return true
				end

				local cursor_before_line = ctx.cursor_before_line
				-- For events
				if cursor_before_line:sub(-1) == '@' then
					return entry.completion_item.label:match('^@')
					-- For props also exclude events with `:on-` prefix
				elseif cursor_before_line:sub(-1) == ':' then
					return entry.completion_item.label:match('^:') and not entry.completion_item.label:match('^:on%-')
				else
					return true
				end
			end
		},
	}) }
