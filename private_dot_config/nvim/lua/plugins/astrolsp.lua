-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      autoformat = true, -- enable or disable auto formatting on start
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = true, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` (:h augroup)
      lsp_document_highlight = {
        -- condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/documentHighlight",
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "CursorHold", "CursorHoldI" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Document Highlighting",
          callback = function() vim.lsp.buf.document_highlight() end,
        },
        {
          event = { "CursorMoved", "CursorMovedI", "BufLeave" },
          desc = "Document Highlighting Clear",
          callback = function() vim.lsp.buf.clear_references() end,
        },
      },
    },
    -- Configure buffer local user commands to add when attaching a language server
    commands = {
      Format = {
        function() vim.lsp.buf.format() end,
        -- condition to create the user command
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        cond = "textDocument/formatting",
        -- the rest of the user command options (:h nvim_create_user_command)
        desc = "Format file with LSP",
      },
    },
    -- Configure default capabilities for language servers (`:h vim.lsp.protocol.make_client.capabilities()`)
    capabilities = {
      textDocument = {
        foldingRange = { dynamicRegistration = false },
      },
    },
    -- Configure language servers for `lspconfig` (`:h lspconfig-setup`)
    config = {

      clangd = {
        capabilities = {
          offsetEncoding = "utf-8",
        },
      },
    },
    -- A custom flags table to be passed to all language servers  (`:h lspconfig-setup`)
    flags = {
      exit_timeout = 5000,
    },
    -- Configuration options for controlling formatting with language servers
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        -- enable or disable format on save globally
        enabled = true,
        -- enable format on save for specified filetypes only
        allow_filetypes = {
          "go",
        },
        -- disable format on save for specified filetypes
        ignore_filetypes = {
          "python",
        },
      },
      -- disable formatting capabilities for specific language servers
      disabled = {
        "lua_ls",
      },
      -- default format timeout
      timeout_ms = 1000,
      -- fully override the default formatting function
      filter = function(client) return true end,
    },
    -- Configure how language servers get set up
    handlers = {
      -- default handler, first entry with no key
      function(server, opts) require("lspconfig")[server].setup(opts) end,
      -- custom function handler for pyright
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end,

      -- rust_analyzer = false,
    },
    -- Configure `vim.lsp.handlers`
    lsp_handlers = {
      -- ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", silent = true }),
      -- ["textDocument/signatureHelp"] = false, -- set to false to disable any custom handlers
    },
    -- Configuration of mappings added when attaching a language server during the core `on_attach` function
    -- The first key into the table is the vim map mode (`:h map-modes`), and the value is a table of entries to be passed to `vim.keymap.set` (`:h vim.keymap.set`):
    --   - The key is the first parameter or the vim mode (only a single mode supported) and the value is a table of keymaps within that mode:
    --     - The first element with no key in the table is the action (the 2nd parameter) and the rest of the keys/value pairs are options for the third parameter.
    --       There is also a special `cond` key which can either be a string of a language server capability or a function with `client` and `bufnr` parameters that returns a boolean of whether or not the mapping is added.
    mappings = {
      -- map mode (:h map-modes)
      n = {
        -- a binding with no condition and therefore is always added
        gl = {
          function() vim.diagnostic.open_float() end,
          desc = "Hover diagnostics",
        },
        -- condition for only server with declaration capabilities
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        -- condition with a full function with `client` and `bufnr`
        ["<leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client, bufnr)
            return client.server_capabilities.semanticTokensProvider and vim.lsp.semantic_tokens
          end,
        },
      },
    },
    -- A list like table of servers that should be setup, useful for enabling language servers not installed with Mason.
    servers = { "veridian" },
    -- A custom `on_attach` function to be run after the default `on_attach` function, takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr) client.server_capabilities.semanticTokensProvider = nil end,
  },
}
