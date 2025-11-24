# smartclose.nvim
---
A Neovim plugin for intelligently closing brackets and quotation marks with a single keymap and with smart Enter key formatting.

## Features
- Smart Closing: Automatically close the last open bracket or quotation mark with a single keymap.
- Smart Step-Over: Keymap to close last open bracket will step over instead of adding a duplicate.
- Smart Enter: Pressing enter after opening a bracket creates closing bracket on new line after cursor. Will avoid creating duplicates if there already is a closing bracket after the open bracket.
- Escape Handling: Will ignore escaped characters.

## Installation

Install using plugin manager, for example Lazy or Packer.
```lua
use('BatoRoy/smartclose.nvim')
```
### Lazy.nvim
```lua
{
    'BatoRoy/smartclose.nvim',
    config = function()
        require('smartclose').setup()
    end
}
```
### Packer
```lua
use {
    'BatoRoy/smartclose.nvim',
    config = function()
        require('smartclose').setup()
    end
}
``

## Setup

To initialize the plugin, you need to require `smartclose` and call the setup function.
```lua
-- Use all defaults.
require("smartclose").setup()

-- Or set arguments.
require("smartclose").setup({
    keymap = '<C-d>',           -- Default: <C-d>
    enable_smart_enter = true   -- Default: true
})
```

## Usage

When in insert mode, trigger the plugin using your configured keymap (default `Ctrl-d`) to automatically close the last open bracket or quotation mark on the current line. The closing character will be inserted at the cursor position. If the character after the cursor is the correct closing character, then the cursor will step over it without adding another closing bracket or quotation mark. 

Supported pairs:
- `( )`
- `{ }`
- `[ ]`
- `" "`
- `' '`

## License
MIT
