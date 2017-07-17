# fish-def

[![Build Status][travis-badge]][travis-link]
[![Slack Room][slack-badge]][slack-link]

Manage your own functions/completions easily!

The differences between `funced` is

- `def` manages `*.fish` files directly without making temporary files.
    - Edited file names are not changed at all times, so you can use undo-history of your editor.
- You can remove the definition files `*.fish` themselves not only the function definitions.
- When you edit, list or erase functions, ones installed with plugin managers are ignored.
    - You can make your own function overwriting plugin's with `--force` option.

## Usage

```fish
def [options] function-names...
```

### Edit

Edit your function with `def`.

```fish
def foo # EDITOR runs to edit ~/.config/fish/functions/foo.fish.
```

You cannot touch functions defined by fish itself or external plugins.

```
def def
def: 'def' might be a builtin or defined by a plugin
      if you want to overwrite it, use --force option
```

If you want to overwrite them, use `--force` option

```
def --force def
```

### Erase

`functions -e` cannot remove autoload functions but `def -e` can do it.

```
def --erase foo # foo.fish is removed without confirmation.
```

### List up

List up the function definitions you wrote. Aliases in `~/.config/fish/functions` are ignored.

```
def --list
```

### Completios

If you add `--complete` flag, you can edit, remove or list up completions instead of functions.

```fish
def -c foo  # edit ~/.config/fish/completions
def -ce foo # remove it
def -cl     # list up the completions you wrote
```

## Setup
### Optional

If you do not use `~/.config/fish/functions` or `~/.config/fish/functions`, set your directory.
```
set -U def_function_path ~/my/function/dir
set -U def_complete_path ~/my/complete/dir
```

The current root directories for function/completion definitions are printed by `--root` option.

```
def -r # ~/my/function/dir
```

## Install

With [fisherman]

```
fisher ryotako/fish-def
```

[travis-link]: https://travis-ci.org/ryotako/fish-def
[travis-badge]: https://img.shields.io/travis/ryotako/fish-def.svg
[slack-link]: https://fisherman-wharf.herokuapp.com
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg
[fisherman]: https://github.com/fisherman/fisherman
