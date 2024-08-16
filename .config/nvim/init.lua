--██╗███╗   ██╗██╗████████╗██╗     ██╗   ██╗ █████╗ 
--██║████╗  ██║██║╚══██╔══╝██║     ██║   ██║██╔══██╗
--██║██╔██╗ ██║██║   ██║   ██║     ██║   ██║███████║
--██║██║╚██╗██║██║   ██║   ██║     ██║   ██║██╔══██║
--██║██║ ╚████║██║   ██║██╗███████╗╚██████╔╝██║  ██║
--╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
--==================================================

-- Global Options (vim.o)

-- Local Window Options (vim.wo)
vim.wo.number = true

-- Local Buffer Optionsn (vim.bo)
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2

-- Keybindings

-- ctrl+S to save
local keymap = vim.api.nvim_set_keymap
keymap('n', '<c-s>', ':w<CR>', {})
keymap('i', '<c-s>', '<Esc>:w<CR>a', {})

-- split navigation with ctrl + (i/j/k/l)
local opts = { noremap = true }
keymap('n', '<c-j>', '<c-w>j', opts)
keymap('n', '<c-h>', '<c-w>h', opts)
keymap('n', '<c-k>', '<c-w>k', opts)
keymap('n', '<c-l>', '<c-w>l', opts)


-- Package Manager
require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'mhinz/vim-signify'
  use 'tpope/vim-fugitive'
  use 'tpope/vim-rhubarb'
  use 'junegunn/gv.vim'
  use 'vim-denops/denops.vim'
  use 'skanehira/denops-docker.vim'
  use 'ahmedkhalf/project.nvim'
  use 'mfussenegger/nvim-dap'
  use 'kyazdani42/nvim-web-devicons' 
--  use 'elkowar/yuck.vim'
--  use 'mfussenegger/nvim-jdtls'
--  use {
--    'nvim-tree/nvim-tree.lua',
--    requires = {
--      'nvim-tree/nvim-web-devicons', -- optional, for file icons
--    },
--    tag = 'nightly' -- optional, updated every week. (see issue #1193)
--  }
end)

-- Plugins

-- project
local project = require("project_nvim").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
}

-- git
--keymap('n', '<leader>gj',  
-- tree-sitter
local configs = require'nvim-treesitter.configs'
configs.setup {
  ensure_installed = "all", -- Only use parsers that are maintained
  highlight = {
    enable = true, 
  },
  indent = {
  enable = true,
  }
}

-- LSP
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function(server)
  local opts = {}
  if server.name == "sumneko_lua" then
    opts = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim', 'use' }
          },
          --workspace = {
            -- Make the server aware of Neovim runtime files
            --library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true}
          --}
        }
      }
    }
  end
  server:setup(opts)
end)

local function nkeymap(key, map)
  keymap('n', key, map, opts)
end

nkeymap('gd', ':lua vim.lsp.buf.definition()<cr>')
nkeymap('gD', ':lua vim.lsp.buf.declaration()<cr>')
nkeymap('gi', ':lua vim.lsp.buf.implementation()<cr>')
nkeymap('gw', ':lua vim.lsp.buf.document_symbol()<cr>')
nkeymap('gw', ':lua vim.lsp.buf.workspace_symbol()<cr>')
nkeymap('gr', ':lua vim.lsp.buf.references()<cr>')
nkeymap('gt', ':lua vim.lsp.buf.type_definition()<cr>')
nkeymap('K', ':lua vim.lsp.buf.hover()<cr>')
nkeymap('<c-k>', ':lua vim.lsp.buf.signature_help()<cr>')
nkeymap('<leader>af', ':lua vim.lsp.buf.code_action()<cr>')
nkeymap('<leader>rn', ':lua vim.lsp.buf.rename()<cr>')

-- completion
local cmp = require'cmp'

cmp.setup({
      mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
--require('lspconfig')['rust_analyzer'].setup {
--  capabilities = capabilities
--}

-- folding
--vim.opt.foldmethod = "expr"
--vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
-- examples for your init.lua


---- nvim-tree icons 
--require'nvim-web-devicons'.setup {
-- -- your personnal icons can go here (to override)
-- -- you can specify color or cterm_color instead of specifying both of them
-- -- DevIcon will be appended to `name`
-- override = {
--  zsh = {
--    icon = "",
--    color = "#428850",
--    cterm_color = "65",
--    name = "Zsh"
--  }
-- };
-- -- globally enable different highlight colors per icon (default to true)
-- -- if set to false all icons will have the default icon's color
-- color_icons = true;
-- -- globally enable default icons (default to false)
-- -- will get overriden by `get_icons` option
-- default = true;
--}
--
---- nvim tree
---- disable netrw at the very start of your init.lua (strongly advised)
--vim.g.loaded = 1
--vim.g.loaded_netrwPlugin = 1
--
--require("nvim-tree").setup({
--  sort_by = "case_sensitive",
--  view = {
--    adaptive_size = true,
--    mappings = {
--      list = {
--        { key = "u", action = "dir_up" },
--      },
--    },
--  },
--  renderer = {
--    group_empty = true,
--  },
--  filters = {
--    dotfiles = true,
--  },
--})

-- debugging
-- vim.keymap.set("n", "<F9>", ":lua require'dap'.continue()<CR>")
-- vim.keymap.set("n", "<F8>", ":lua require'dap'.step_over()<CR>")
-- vim.keymap.set("n", "<S-F9>", ":lua require'dap'.step_out()<CR>")
-- vim.keymap.set("n", "<F7>", ":lua require'dap'.step_into()<CR>")
-- vim.keymap.set("n", "<F2>", ":lua require'dap'.toggle_breakpoint()<CR>")
-- vim.keymap.set("n", "<F3>", ":lua require'dap'.repl.open()<CR>", {buffer=0})
-- local dap = require('dap')
-- dap.adapters.lldb = {
--   type = 'executable',
--   command = '/usr/bin/lldb-vscode', 
--   name = 'lldb'
-- }
-- -- C, C++, Rust
-- dap.configurations.cpp = {
--   {
--     name = 'Launch',
--     type = 'lldb',
--     request = 'launch',
--     program = function()
--       return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
--     end,
--     cwd = '${workspaceFolder}',
--     stopOnEntry = false,
--     args = {},
-- 
--     -- 💀
--     -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
--     --
--     --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
--     --
--     -- Otherwise you might get the following error:
--     --
--     --    Error on launch: Failed to attach to the target process
--     --
--     -- But you should be aware of the implications:
--     -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
--     -- runInTerminal = false,
--   },
-- }
-- 
-- -- If you want to use this for Rust and C, add something like this:
-- 
-- dap.configurations.c = dap.configurations.cpp
-- dap.configurations.rust = dap.configurations.cpp
-- -- Java
-- 
-- local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
-- local home = os.getenv "HOME"
-- WORKSPACE_PATH = home .. "/workspace/"
-- local workspace_dir = WORKSPACE_PATH .. project_name
-- 
-- local config = {
--   -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
--   cmd = {
--   -- This is the default if not provided, you can remove it. Or adjust as needed.
--   -- One dedicated LSP server & client will be started per unique root_dir  
--     'java', -- or '/path/to/java17_or_newer/bin/java'
--             -- depends on if `java` is in your $PATH env variable and if it points to the right version.
-- 
--     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
--     '-Dosgi.bundles.defaultStartLevel=4',
--     '-Declipse.product=org.eclipse.jdt.ls.core.product',
--     '-Dlog.protocol=true',
--     '-Dlog.level=ALL',
--     '-Xms1g',
--     '--add-modules=ALL-SYSTEM',
--     '--add-opens', 'java.base/java.util=ALL-UNNAMED',
--     '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
--     '-jar', '/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
--     '-configuration', '/usr/share/java/jdtls/config_linux',
--     '-data', workspace_dir,
--   },
-- 
-- 
--   root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew'}),
--   -- Here you can configure eclipse.jdt.ls specific settings
--   -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
--   -- for a list of options
--   settings = {
--     java = {
--     }
--   },
-- 
--   -- Language server `initializationOptions`
--   -- You need to extend the `bundles` with paths to jar files
--   -- if you want to use additional eclipse.jdt.ls plugins.
--   --
--   -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--   --
--   -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
--   init_options = {
--     bundles = {}
--   },
-- }
-- require('jdtls').start_or_attach(config)
-- config['on_attach'] = function(client, bufnr)
--   -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
--   -- you make during a debug session immediately.
--   -- Remove the option if you do not want that.
--   -- You can use the `JdtHotcodeReplace` command to trigger it manually
--   require('jdtls').setup_dap({ hotcodereplace = 'auto' })
-- end
