# fish-def

[![Build Status][travis-badge]][travis-link]
[![Slack Room][slack-badge]][slack-link]

## Install

With [fisherman]

```
fisher ryotako/fish-def
```

## Usage

```fish
NAME: def - Manage your local function definitions

USAGE: def [options] function ...

OPTIONS:
    -c, --complete  edit/erase/list completions instead of functions
    -e, --erase     erase user defined functions
    -f, --force     overwirte function/completion defined by a plugin
    -l, --list      list user defined functions 
    -r, --root      print root directory
    -h, --help      show this help
```

[travis-link]: https://travis-ci.org/ryotako/fish-def
[travis-badge]: https://img.shields.io/travis/ryotako/fish-def.svg
[slack-link]: https://fisherman-wharf.herokuapp.com
[slack-badge]: https://fisherman-wharf.herokuapp.com/badge.svg
[fisherman]: https://github.com/fisherman/fisherman
