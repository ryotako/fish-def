function def -d 'manage fish functions/complitons'

    # --help option: show usage and exit
    function __def_usage
        echo "NAME: def - Manage your local function definitions"
        echo
        echo "USAGE: def [options] function ..."
        echo
        echo "OPTIONS:"
        echo "    -c, --complete  edit/erase/list completions instead of functions"
        echo "    -e, --erase     erase user defined functions"
        echo "    -f, --force     overwirte function/completion defined by a plugin"
        echo "    -l, --list      list user defined functions "
        echo "    -r, --root      print root directory"
        echo "    -h, --help      show this help"
    end

    # if the function is builtin or defined by a plugin, return 1
    function __def_is_your_own -a name root
        set -l path (string escape -n (realpath "$root")/"$name.fish")

        if functions -q "$name"
            test -f "$path" -a "$path" = (realpath "$path")
            or return 1
        end
    end


    set -l key
    set -l value
    set -l type function
    set -l names
    set -l option
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
                set option $option erase

            case -l --list
                set option $option list

            case -r --root
                set option $option root

            case -h --help
                __def_usage
                return 1
        end
    end

    if test -z "$key" # option parsing error
        return 1
    end

    if test (count $option) -lt 1
        set option edit # set default action
    else if test (count $option) -gt 1 # check invalid option combination
        echo "def: invalid combination of options" >&2
        return 1
    end

    # switch the type: function/completion
    test -n "$XDG_CONFIG_HOME"
    and set config_home "$XDG_CONFIG_HOME"
    or set config_home "$HOME/.config"

    set -l config_fish "$config_home/fish"

    set -l root
    switch "$type"
        case function
            test -n "$def_function_path"
            and set root "$def_function_path"
            or set root "$config_fish"/functions
        case completion
            test -n "$def_complete_path"
            and set root "$def_complete_path"
            or set root "$config_fish"/completions
    end

    switch $option
        case root # print the root path for functions/completions
            echo $root

        case list # list functions/completions
            for path in $root/*.fish
                set path (string escape -n "$path")

                if test "$path" = (realpath "$path" ^/dev/null; or echo)
                    basename "$path" .fish
                end
            end

        case erase # erase functions/completions
            if not count $names >/dev/null
                echo "def: $type name is required" >&2
                return 1
            end

            set -l error 0
            for name in $names
                set -l path (string escape -n "$root/$name.fish")

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

            set -l path (string escape -n "$root/$name.fish")

            eval "$EDITOR $path"
            or return 1
            
            test -f "$path"
            and source "$path"
    end
end
