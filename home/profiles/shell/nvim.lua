-- general
vim.opt.autowrite = true
vim.opt.mouse = '' -- disable mouse
vim.opt.relativenumber = true
vim.opt.scrolloff = 5

-- tabs
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- make
vim.keymap.set('n', '<leader>b', ':make<CR>')

-- quickfix
vim.keymap.set('n', '<leader>o', ':copen<CR>')
vim.keymap.set('n', '<leader>q', ':cclose<CR>')
vim.keymap.set('n', '<C-n>', ':cnext<CR>')
vim.keymap.set('n', '<C-p>', ':cprev<CR>')

-- per-filetype settings, general
vim.api.nvim_create_autocmd("FileType", {
	pattern = 'markdown',
	callback = function()
		vim.opt.textwidth = 80
	end,
})

-- theming
vim.cmd [[ colorscheme dracula ]]
vim.opt.termguicolors = true

-- tree-sitter
require'nvim-treesitter.configs'.setup {
	highlight = { enable = true },
	indent = { enable = true },
}
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

-- lsp
local lspconfig = require'lspconfig'

-- servers
lspconfig.nixd.setup {
	settings = {
		nixd = {
			formatting = {
				command = "nixfmt"
			}
		}
	}
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local opts = { buffer = args.buf }
		-- navigation
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
		vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
	end,
})

-- autoformat
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		vim.lsp.buf.format()
	end,
})

-- completion
local cmp = require'cmp'
cmp.setup {
	mapping = cmp.mapping.preset.insert {
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
	}, {
		{ name = 'buffer' },
	}),
}
