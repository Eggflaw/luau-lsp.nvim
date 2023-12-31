local log = require "luau-lsp.log"
local util = require "luau-lsp.util"

local M = {}

---@param opts? LuauLspConfig
function M.setup(opts)
  require("luau-lsp.config").setup(opts)
end

function M.compute_bytecode()
  require("luau-lsp.bytecode").compute_bytecode()
end

function M.compiler_remarks()
  require("luau-lsp.bytecode").compiler_remarks()
end

function M.treesitter()
  local success, parsers = pcall(require, "nvim-treesitter.parsers")
  if not success then
    log.error "nvim-treesitter not found"
    return
  end

  parsers.get_parser_configs().luau = {
    install_info = {
      url = "https://github.com/polychromatist/tree-sitter-luau",
      files = { "src/parser.c", "src/scanner.c" },
      -- HACK: manually set the revision since treesitter has its own parser & revision for luau
      revision = util.parser_revision(),
    },
  }

  -- HACK: override the given query just in case of treesitter's queries are found first
  local function override_query(query_type)
    vim.treesitter.query.set("luau", query_type, util.get_query(query_type))
  end

  override_query "folds"
  override_query "highlights"
  override_query "indents"
  override_query "injections"
  override_query "locals"
end

return M
