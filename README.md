:us: [:jp:](https://github.com/ryotako/fish-def/wiki)
# fish-def

[![Build Status][travis-badge]][travis-link]
[![Slack Room][slack-badge]][slack-link]

Manage your own functions/completions easily!

The differences between `funced` is

- Manage `*.fish` files directly without making temporary files.
    - So you can use undo-history of your editor.
- Enable to remove a definition file `*.fish` itself not only the function definition.
- Manage your own functions, ones installed with plugin managers are ignored.

## Usage

```fish
def [options] function-names...
```

### Edit

Edit your function with `def`. If you want to overwrite a function provided by a plugin, use `--force` option

```fish
def foo         # EDITOR runs to edit ~/.config/fish/functions/foo.fish.
def --force def # overwrite a function provided by a plugin
```

### Erase

`functions -e` cannot remove autoload functions but `def -e` can do it.

```
def --erase foo # foo.fish is removed without confirmation.
def --erase def
def: 'def' might be a builtin or defined by a plugin
      if you want to remove it, use --force option
```

### List up

List up the function definitions you wrote. Aliases in `~/.config/fish/functions` are ignored.

```
def --list
```

### Completios

If you add `--complete` flag, you can edit, remove or list up completions instead of functions.

```fish
def -c foo         # edit ~/.config/fish/completions
def -c --erase foo # remove it
def -c --list      # list up the completions you wrote
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
def -r  # ~/my/function/dir
def -cr # ~/my/complete/dir
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
