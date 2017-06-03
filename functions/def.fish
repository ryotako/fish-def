function def -d 'manage fish functions/complitons'
    set -l type function
    set -l root "$HOME/.config/fish/functions"
    set -l paths $fish_function_path
    set -l opts
    set -l names
    while count $argv >/dev/null
        switch $argv[1]
            case -c --complete
                set opts $opts complete
            case -e --erase
                set opts $opts erase
            case -l --list
                set opts $opts list
            case -r --root
                set opts $opts root
            case -h --help
                set opts $opts help
            case --
                if set -q argv[2]
                    set names $argv[2]
                    set -e $argv[2]
                end
            case '-*'
                echo "def: invalid option '$argv[1]'" >/dev/stderr
                return 1
            case '*'
                set names $names $argv[1]
        end
        set -e argv[1]
    end

    # --help option
    # show usage and exit
    if contains help $opts
        string trim "
NAME: def - Manage your local function definitions

USAGE: def [options] function ...

OPTIONS:
    -c, --complete  edit/erase/list completions instead of functions
    -e, --erase     erase user defined functions
    -l, --list      list user defined functions 
    -r, --root      print root directory
    -h, --help      show this help
"
        return
    end

    # --complete option
    # change the targets from functions to completions
    if contains complete $opts
        set type completion
        set root "$HOME/.config/fish/completions"
        set paths $fisn_complete_path
    end

    # --root option
    # print the root path for functions/completions
    if contains root $opts
        echo "$root"
        return
    end

    # --list option
    # list functions/completions and exit
    if contains list $opts
        for path in $root/*.fish
            if test "$path" = (realpath "$path" ^/dev/null; or echo)
                basename -s '.fish' $path
            end
        end
        return
    end

    # --erase option
    # erase functions/completions and exit
    if contains erase $opts
        set -l error 0
        for name in $names
            if test -f "$root/$name.fish"
                rm "$root/$name.fish"
                or set error (math $error + 1)
            else
                echo "$type '$name' is not in $root" >&2
                set error (math $error + 1)
            end
        end
        return $error
    end

    # check the number of arguments
    if test (count $names) -gt 1
        echo "def: too many arguments" >/dev/stderr
        return 1
    else if test -z "$names[1]"
        echo "def: $type name is required"
        return 1
    end

    set -l name "$names[1]"

    # check the function / completion names
    if not string match -iqr '[a-z0-9_+:]+' "$name"
        echo "def: invalid $type name '$name'"
        return 1
    end

    # get the path of the function / completion
    set -l path
    for file in $paths/$name.fish
        if test -f "$file"
            set path "$file"
            break
        end
    end

    # an undefined function?
    set -l undef 0
    if test -z "$path"
        set path "$root/$name.fish"
        set undef 1
    end

    # a builtin function or function installed by fundle?
    if not test "$path" = "$root/$name.fish"
        echo "def: $type '$name' is not in $root" >/dev/stderr
        return 1
    end

    # a function installed by fisherman？
    if not test "$path" = (realpath "$path")
        echo "def: $type '$name' in $root is an alias" >/dev/stderr
        return 1
    end

    # edit the function/completion

    eval "$EDITOR $path"

    if test -f "$path"
        if not contains complete $opts
            source "$path"
        else
            complete -e >/dev/null
        end
    else
        return 1
    end
end
