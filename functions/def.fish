function def -d 'manage fish functions/complitons'

    # if the function is builtin or defined by a plugin, return 1
    function __def_is_your_own -a name root
        set -l path (realpath "$root" ^/dev/null; or echo "$root")/"$name.fish"

        if contains "$name" (functions -a)
            test -f "$path" -a "$path" = (realpath "$path" ^/dev/null; or echo)
            or return 1
        end
    end

    argparse --name def --exclusive 'e,l,r'\
        'c/complete' 'e/erase' 'f/force' 'l/list' 'r/root' 'h/help' -- $argv
    or return 1

    if set -lq _flag_h
        echo "NAME: def - Manage your local function definitions"
        echo
        echo "USAGE: def [options] function-names..."
        echo
        echo "OPTIONS:"
        echo "    -c, --complete  edit/erase/list completions instead of functions"
        echo "    -e, --erase     erase user defined functions"
        echo "    -f, --force     overwirte function/completion defined by a plugin"
        echo "    -l, --list      list user defined functions "
        echo "    -r, --root      print root directory"
        echo "    -h, --help      show this help"
        echo
        echo "VARIABLES:"
        echo "    def_function_path  root directory for function definitions"
        echo "    def_complete_path  root directory for completion definitions"
        return
    end

    set -lq _flag_c
    and set -l type completion
    or  set -l type function

    set -lq _flag_f
    and set -l forced true
    or  set -l forced false

    count $argv >/dev/null
    and set -l action edit
    or  set -l action list

    set -lq _flag_e
    and set action erase
 
    set -lq _flag_l
    and set action list

    set -lq _flag_r
    and set action root

    # set the path to save functions/completions
    test -n "$XDG_CONFIG_HOME"
    and set -l config_home "$XDG_CONFIG_HOME"
    or  set -l config_home "$HOME/.config"

    set -l config_fish "$config_home/fish"

    set -l root
    switch "$type"
        case function
            test -n "$def_function_path"
            and set root "$def_function_path"
            or  set root "$config_fish"/functions
        case completion
            test -n "$def_complete_path"
            and set root "$def_complete_path"
            or  set root "$config_fish"/completions
    end

    switch "$action"
        case root # print the root path for functions/completions
            echo "$root"

        case list # list functions/completions
            if test -d "$root"
                ls -F "$root" | sed -n "s/\.fish\$//p"
            end | if isatty stdout
                cat - | string join ', '
            else
                cat -
            end

        case erase # erase functions/completions
            if not count $argv >/dev/null
                echo "def: $type name is required" >&2
                return 1
            end

            set -l error 0
            for name in $argv
                set -l path "$root/$name.fish"

                if not test -f "$path"
                    echo "$type '$name' is not in $root" >&2
                    set error (math $error + 1)
                    continue
                end

                if begin; test "$forced" = false; and not __def_is_your_own "$name" "$root"; end

                    echo "def: '$name' might be a builtin or defined by a plugin" >&2
                    echo "      if you want to remove it, use --force option" >&2
                    set error (math $error + 1)
                    continue
                end

                if test "$type" = function
                    functions -e "$name"
                end

                rm "$path"
                or set error (math $error + 1)
            end
            return $error # the number of failures

        case edit
            # check the number of arguments
            if test (count $argv) -gt 1
                echo "def: too many arguments" >&2
                return 1
            else if test -z "$argv[1]"
                echo "def: $type name is required" >&2
                return 1
            else if string match -rq '^-|/' -- "$argv"
                echo "def: '$argv' is an invalid function name" >&2
                return 1
            end

            set -l name $argv[1]

            if begin; test "$forced" = false; and not __def_is_your_own "$name" "$root"; end

                echo "def: '$name' might be a builtin or defined by a plugin" >&2
                echo "      if you want to overwrite it, use --force option" >&2
                return 1
            end

            command mkdir -p $root
            or return 1

            set -l path "$root/$name.fish"

            eval "$EDITOR "(string escape $path)
            or return 1

            test -f "$path"
            and source "$path"
    end
end
