# smartclose.nvim
---
This is a plugin for closing open brackets and quotation marks with a single keymap. 
## Installation

Install using plugin manager, for example packer.
```lua
use('BatoRoy/smartclose.nvim')
```
## Setup

To initialize the plugin, you need to require "smartclose". Use the *set_keymap* function to change the keymap for triggering the plugin. The default keymap is set to *Ctrl + s*.
```lua
require("smartclose").set_keymap("<C-s>")
```

## Usage

When in insert mode, trigger the plugin (using the set keymap) to automatically close the last open bracket or quotation mark on the current line. The closing character will be inserted at the cursor position. If the character after the cursor is the correct closing character, then the cursor will step over it without adding another closing bracket or quotation mark. 

Will close:
- ( )
- { }
- \[ ]
- " "
- ' '
## Disclaimer
This is my first Neovim plugin. 
