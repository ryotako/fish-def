function setup
    set -g __test_def_function_path (mktemp -d)
    set -g __test_def_complete_path (mktemp -d)

    set -g def_function_path "$__test_def_function_path"
    set -g def_complete_path "$__test_def_complete_path"
end

function teardown
    rm -rf "$__test_def_function_path"
    rm -rf "$__test_def_complete_path"
end

test "root directory for functions"
    "$__test_def_function_path" = (def -r)
end

test "root directory for completions"
    "$__test_def_complete_path" = (def -cr)
end
