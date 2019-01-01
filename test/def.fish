#
# setup & teardown
#

function setup
    mkdir ./tmp
    set -g __test_def_function_path ./tmp
    set -g __test_def_complete_path ./tmp

    set -g def_function_path "$__test_def_function_path"
    set -g def_complete_path "$__test_def_complete_path"
    set -g fish_complete_path "$__test_def_complete_path"

    function __test_def_function_editor -a path
        set -l name (basename "$path" .fish)
        begin
            echo "function $name"
            echo "  echo $name"
            echo "end"
        end > "$path"
    end

    function __test_def_completion_editor -a path
        set -l name (basename "$path" .fish)
        echo "complete -c $name -s a" > "$path"
    end

    set -g EDITOR __test_def_function_editor
end

function teardown
    rm -rf "$__test_def_function_path"
    rm -rf "$__test_def_complete_path"
end

#
# tests
#

test "--help option"
    (count (def --help)) -gt 0
end

test "--root option"
    "$__test_def_function_path" = (def --root)
end

test "--root --complete option"
    "$__test_def_complete_path" = (def --complete --root)
end

test "edit a new function"
    (def foo) foo = (foo) (functions -e foo)
end

test "edit a new completion"
    (set -g EDITOR __test_def_completion_editor
    def --complete foo) "-a" = (complete -C"foo -")
end

test "--list option"
    (def foo; def bar) foo bar = (def --list) (functions -e foo bar)
end

test "--list --complete option"
    (set -g EDITOR __test_def_completion_editor
    def --complete foo
    def --complete bar) foo bar = (def --list --complete)
end

test "--erase option"
    (def foo; def --erase foo) 0 = (count (def --list))
end

test "--erase --complete option"
    (set -g EDITOR __test_def_completion_editor
    def --complete foo
    def --erase --complete foo) 0 = (count (def --list --complete))
end

test "--force option"
    (def --force def) def = (def) (source ./functions/def.fish)
end

test "--force --complete option"
    (set -g EDITOR __test_def_completion_editor
    def --force --complete def) "-a" = (complete -C"def -")
end

