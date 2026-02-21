# purgatory.nvim

A minimal Neovim plugin that opens a floating window for editing a text file — perfect for a scratchpad, todo list, or anything stuck in limbo.

## Features

- Opens any text file in a centered floating window
- Saves directly back to the file on `:w`
- Configurable size, border, filepath, and keymaps
- Accepts an optional filepath argument via the `:Purgatory` command


## Installation

Requires git to be installed.

**[lazy.nvim](https://github.com/folke/lazy.nvim)**

```lua
{
  "ratludu/purgatory.nvim",
  opts = {},
}
```

**[packer.nvim](https://github.com/wbthomason/packer.nvim)**

```lua
use {
  "ratludu/purgatory.nvim",
  config = function()
    require("purgatory").setup()
  end,
}
```

## Usage

Open the default file in a floating window:

```
:Purgatory
```

Inside the window:

| Key       | Action      |
|-----------|-------------|
| `<Esc>`   | Close       |
| `q`       | Close       |
| `:w`      | Save        |

## Configuration

Pass options to `setup()` to override the defaults:

```lua
require("purgatory").setup({
  width_percent = 0.8,       -- window width as a fraction of the editor
  height_percent = 0.8,      -- window height as a fraction of the editor
  border = "rounded",        -- border style: "none" | "single" | "double" | "rounded" | "solid" | "shadow"
  keymaps = {
    open = "<leader>pg",      -- keymap to open purgatory (optional)
    close = { "<Esc>", "q" },
  },
})
```

### Defaults

| Option           | Default          |
|------------------|------------------|
| `filepath`       | `./todo.txt`     |
| `width_percent`  | `0.8`            |
| `height_percent` | `0.8`            |
| `border`         | `"rounded"`      |
| `keymaps.close`  | `{ "<Esc>", "q" }` |
| `keymaps.open`   | `nil`            |

## License

MIT
