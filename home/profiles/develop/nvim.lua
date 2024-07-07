-- More dev-oriented settings

-- Go
lspconfig.gopls.setup {
	on_attach = function(client, bufnr)
		-- format w/ goimports
		-- ref: https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
		vim.api.nvim_create_autocmd('BufWritePre', {
			buffer = bufnr,
			callback = function()
				local params = vim.lsp.util.make_range_params()
				params.context = { only = { 'source.organizeImports' } }

				local ret = client.request_sync('textDocument/codeAction', params, 1000, bufnr)
				if ret and ret.result then
					for _, res in pairs(ret.result) do
						if res.edit then
							local enc = client.offset_encoding or 'utf-16'
							vim.lsp.util.apply_workspace_edit(res.edit, enc)
						end
					end
				end
			end,
		})

		local opts = { buffer = bufnr }

		vim.keymap.set('n', '<leader>b', '<Plug>(go-build)', opts)
		vim.keymap.set('n', '<leader>t', '<Plug>(go-test)', opts)
		vim.keymap.set('n', '<leader>T', '<Plug>(go-test-compile)', opts)
		vim.keymap.set('n', '<leader>c', '<Plug>(go-coverage-toggle)', opts)
		vim.keymap.set('n', '<leader>a', '<Plug>(go-alternate-edit)', opts)

		-- let lspconfig handle most features
		vim.g.go_code_completion_enabled = 0
		vim.g.go_def_mapping_enabled = 0
		vim.g.go_doc_keywordprg_enabled = 0
		vim.g.go_fmt_autosave = 0
		vim.g.go_gopls_enabled = 0
		vim.g.go_imports_autosave = 0
		vim.g.go_mod_fmt_autosave = 0
		vim.g.go_template_autocreate = 0
	end
}

-- templ not autodetected for some reason
vim.filetype.add { extension = { templ = 'templ' } }

-- Simpler configs
lspconfig.jsonls.setup {}
lspconfig.tailwindcss.setup {
	-- add templ
	-- NOTE: remove after upgrade
	filetypes = { "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango", "edge", "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars", "hbs", "html", "html-eex", "heex", "jade", "leaf", "liquid", "markdown", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "css", "less", "postcss", "sass", "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue", "svelte", "templ" },
	init_options = {
		userLanguages = {
			eelixir = "html-eex",
			eruby = "erb",
			templ = "html",
		},
	},
}
lspconfig.helm_ls.setup{}
lspconfig.templ.setup {}
lspconfig.terraformls.setup {}
lspconfig.texlab.setup {}
lspconfig.tsserver.setup {}
lspconfig.yamlls.setup {}
