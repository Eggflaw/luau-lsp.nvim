# luau-lsp.nvim

A [luau-lsp](https://github.com/JohnnyMorganz/luau-lsp/) extension to improve your experience in neovim.

https://github.com/lopi-py/luau-lsp.nvim/assets/70210066/4fa6d3b1-44fe-414f-96ff-b2d58e840080

## Requirements

* Neovim 0.9+ (0.10+ is recommended)
* [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)
* [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)

## Installation

Use your favourite plugin manager to install luau-lsp.nvim

<details>

<summary>lazy.nvim</summary>

```lua
{
  "lopi-py/luau-lsp.nvim",
  opts = {
    ...
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
}
```

</details>

<details>

<summary>packer.nvim</summary>

```lua
use {
  "lopi-py/luau-lsp.nvim",
  config = function()
    require("luau-lsp").setup {
      ...
    }
  end,
  requires = {
    "nvim-lua/plenary.nvim",
    "neovim/nvim-lspconfig",
  },
}
```

</details>

## Quick start

> [!CAUTION]
> `lspconfig.luau_lsp.setup` should **NOT** be called as the plugin does it internally

```lua
require("luau-lsp").setup {
  ...
}
```

### Using mason-lspconfig.nvim

```lua
require("mason-lspconfig").setup_handlers {
  luau_lsp = function()
    require("luau-lsp").setup {
      ...
    }
  end,
}
```

## Roblox

Roblox types are downloaded from the luau-lsp repo and passed to the language server.

```lua
require("luau-lsp").setup {
  platform = {
    type = "roblox",
  },
  types = {
    roblox_security_level = "PluginSecurity",
  },
}
```

### Rojo sourcemap

Sourcemap generation is done by running `rojo sourcemap --watch default.project.json --output sourcemap.json`.

```lua
require("luau-lsp").setup {
  sourcemap = {
    enabled = true,
    autogenerate = true, -- automatic generation when the server is attached
    rojo_project_file = "default.project.json",
  },
}
```

`:LuauRegenerateSourcemap {file}` is provided to start sourcemap generation with the project file passed as argument (optional).

### Companion plugin

You can install the companion plugin [here](https://create.roblox.com/store/asset/10913122509/Luau-Language-Server-Companion?externalSource=www).

```lua
require("luau-lsp").setup {
  plugin = {
    enabled = true,
    port = 3667,
  },
}
```

## Definition files

```lua
require("luau-lsp").setup {
  types = {
    definition_files = { "path/to/definitions/file" },
    documentation_files = { "path/to/documentation/file" },
  },
}
```

## Luau FFLags

```lua
require("luau-lsp").setup {
  fflags = {
    sync = true, -- sync currently enabled fflags with roblox's published fflags
    override = {
      LuauTarjanChildLimit = 0,
    },
  },
}
```

## Bytecode generation

`:LuauBytecode` and `:LuauCompilerRemarks` open a new window and show the current Luau file bytecode and compiler remarks. It will automatically update if you change the file or edit it. Close with `q`.

https://github.com/lopi-py/luau-lsp.nvim/assets/70210066/f9d45153-47f0-4565-a2ed-3769153732a0

## Server configuration

```lua
require("luau-lsp").setup {
  server = {
    settings = {
      -- https://github.com/folke/neoconf.nvim/blob/main/schemas/luau_lsp.json
      ["luau-lsp"] = {
        completion = {
          imports = {
            enabled = true, -- enable auto imports
          },
        },
      },
    },
  },
}
```

## Project configuration

Add the following to your `.nvim.lua`

```lua
require("luau-lsp").config {
  ...
}
```

For more info about `.nvim.lua`, check `:help 'exrc'`

## Configuration

<details>

<summary>Defaults</summary>

```lua
---@class LuauLspConfig
local defaults = {
  platform = {
    ---@type "standard"|"roblox"
    type = "roblox",
  },
  sourcemap = {
    enabled = true,
    autogenerate = true,
    rojo_path = "rojo",
    rojo_project_file = "default.project.json",
    include_non_scripts = true,
  },
  types = {
    ---@type string[]
    definition_files = {},
    ---@type string[]
    documentation_files = {},
    ---@type "None"|"LocalUserSecurity"|"PluginSecurity"|"RobloxScriptSecurity"
    roblox_security_level = "PluginSecurity",
  },
  fflags = {
    enable_by_default = false,
    sync = true,
    ---@type table<string, string>
    override = {},
  },
  plugin = {
    enabled = false,
    port = 3667,
  },
  ---@type table<string, any>
  server = {
    cmd = { "luau-lsp", "lsp" },
    root_dir = function(path)
      local server = require "luau-lsp.server"
      return server.root(path, function(name)
        return name:match ".*%.project.json$"
      end) or server.root(path, {
        ".git",
        ".luaurc",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
      })
    end,
    -- see https://github.com/folke/neoconf.nvim/blob/main/schemas/luau_lsp.json
    settings = {},
  },
}
```

</details>

## FAQ

### Why doesn't the luau filetype detection work?

Don't lazy load the plugin if you are on Neovim v0.9

### Why doesn't the server detect changes in the sourcemap?

Make sure to enable the file watcher capability and pass it in the server options

```lua
-- there are couple ways to get the default capabilities, it depends on your distribution or what completion plugins are you using
local capabilities = vim.lsp.procotol.make_client_capabilities()

-- example using nvim-cmp
capabilities = vim.tbl_deep_extend("force", capabilities, require("nvim_cmp_lsp").default_capabilities())

-- manually enable the file watcher capability so luau-lsp will know when the sourcemap changes
-- only needed if you are running Neovim 0.9 or Linux
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

require("luau-lsp").setup {
  server = {
    capabilities = capabilities,
  },
}
```

### What is the error "server not yet received configuration for diagnostics"?

Neovim is asking for diagnostics to the server but it hasn't loaded the configuration yet, you can just ignore this error. This is patched on Neovim 0.10+

### How to use luau-lsp in a roblox codebase using the .lua extension?

Add this to your config. Requires Neovim 0.10+

```lua
local cwd = assert(vim.uv.cwd())
local rojo_file_found = vim.fs.root(cwd, function(name)
  return name:match "%.project.json$"
end)

if rojo_file_found then
  vim.filetype.add {
    extension = {
      lua = function(path)
        return path:match ".nvim.lua$" and "lua" or "luau"
      end,
    },
  }
end
```
