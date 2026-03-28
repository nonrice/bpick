# BPick

Very fast buffer switcher for Vim

## Install
### vim-plug
```
Plug 'nonrice/bpick'
```

## Usage

Opening new buffers automatically populates empty slots in the buffer list. Deleting a buffer empties its slot, if it was in one.

The following commands can be mapped to keybinds.

### `:BPick`
Type a number to instantly switch to the buffer.

### `:BPickSet`
Provide a slot number to set the current buffer to.

- If the current buffer is already in a slot and target slot is occupied, they are swapped

