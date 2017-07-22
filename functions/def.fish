function def -d 'manage fish functions/complitons'

    # --help option: show usage and exit
    function __def_usage
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
    end

    # if the function is builtin or defined by a plugin, return 1
    function __def_is_your_own -a name root
        set -l path (realpath "$root" ^/dev/null; or echo "$root")/"$name.fish"

        if contains "$name" (functions -a)
            test -f "$path" -a "$path" = (realpath "$path" ^/dev/null; or echo)
            or return 1
        end
    end

    set -l key unparsed
    set -l value
    set -l type function
    set -l names
    set -l action
    set -l forced false

    argu {c,complete} {e,erase} {f,force} {l,list} {r,root} {h,help}\
        -- $argv | while read key value
        switch $key
            case _
                set names $names $value

            case -c --complete
                set type completion

            case -f --force
                set forced true

            case -e --erase
                set action $action erase

            case -l --list
                set action $action list

            case -r --root
                set action $action root

            case -h --help
                __def_usage
                return 1
        end
    end
 
    # check options
    if begin; count $argv >/dev/null; and test "$key" = unparsed; end # option parsing error
        return 1
    else if test (count $action) -gt 1 # invalid option combination
        echo "def: invalid combination of options" >&2
        return 1
    end

    # set the default action
    if test -z "$action"
        set action (count $argv >/dev/null; and echo edit; or echo list)
    end

    # set the path to save functions/completions
    set -l config_home (test -n "$XDG_CONFIG_HOME"
        and echo "XDG_CONFIG_HOME"
        or echo "$HOME/.config")
    set -l config_fish "$config_home/fish"

    set -l root (switch "$type"
        case function
            test -n "$def_function_path"
            and echo "$def_function_path"
            or echo "$config_fish"/functions
        case completion
            test -n "$def_complete_path"
            and echo "$def_complete_path"
            or echo "$config_fish"/completions
    end)

    switch $action
        case root # print the root path for functions/completions
            echo "$root"

        case list # list functions/completions
            test -d "$root"; and ls -F "$root" | sed -n "s/\.fish\$//p"

        case erase # erase functions/completions
            if not count $names >/dev/null
                echo "def: $type name is required" >&2
                return 1
            end

            set -l error 0
            for name in $names
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
            if test (count $names) -gt 1
                echo "def: too many arguments" >&2
                return 1
            else if test -z "$names[1]"
                echo "def: $type name is required" >&2
                return 1
            else if string match -rq '^-|/' -- "$names"
                echo "def: '$names' is an invalid function name" >&2
                return 1
            end

            set -l name $names[1]

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
