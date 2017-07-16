function def -d 'manage fish functions/complitons'

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
                set option $option help
        end
    end

    if test -z "$key" # option parsing error
        return 1
    end

    # --help option: show usage and exit
    if contains help $option
        string trim "
NAME: def - Manage your local function definitions

USAGE: def [options] function ...

OPTIONS:
    -c, --complete  edit/erase/list completions instead of functions
    -e, --erase     erase user defined functions
    -f, --force     overwirte function/completion defined by a plugin
    -l, --list      list user defined functions 
    -r, --root      print root directory
    -h, --help      show this help
"
        return
    end

    if test (count $option) -lt 1 # default action
        set option edit
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
                if test -f "$root/$name.fish"
                    if test "$type" = function
                        functions -e "$name"
                    end
                    rm "$root/$name.fish"
                    or set error (math $error + 1)
                else
                    echo "$type '$name' is not in $root" >&2
                    set error (math $error + 1)
                end
            end
            return $error

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

            # get the path of the function / completion
            set -l path (string escape -n "$root/$name.fish")

            if functions -q $name
                if test ! -f "$path" -a "$forced" = false # builtin or installed by fundle, fresco or omf

                    echo "def: '$name' might be a builtin or defined by a plugin" >&2
                    echo "      if you want to overwrite it, use --force option" >&2
                    return 1

                else if test "$path" != (realpath "$path") -a "$forced" = false # installed by fisherman

                    echo "def: '$name' might be defined by a plugin" >&2
                    echo "      if you want to overwrite it, use --force option" >&2
                    return 1

                end
            end

            command mkdir -p $root
            or return 1

            eval "$EDITOR $path"
            or return 1
            
            test -f "$path"
            and source "$path"
    end
end
