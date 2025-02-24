# Utilities functions

def path_contains [new_path: string, quiet?: bool = true] {
    # if new_path is not in $PATH
    let exists = ($new_path | path expand) in $env.PATH
    if $exists {
        if not $quiet { print $"(ansi bl)(ansi cb)[LOG](ansi reset) (ansi u)($new_path)(ansi reset) already exists in (ansi bo)$env.PATH(ansi reset)" }
    } else {
        if not $quiet { print $"(ansi bl)(ansi cb)[LOG](ansi reset) (ansi u)($new_path)(ansi reset) appended to (ansi bo)$env.PATH(ansi reset)" }
    }
    $exists
}

def safe_expand_path [path: string] {
    let exists = ($path | path expand) in $env.PATH
    if not $exists { $path } else { null }
}

def env_contains [path_name: string, path_value: string, quiet?: bool = true] {
    let paths = $env | get $path_name
    let exists = ($path_value | path expand) in $paths
    if $exists {
        if not $quiet { print $"(ansi bl)(ansi cb)[LOG](ansi reset) (ansi u)($path_value)(ansi reset) already exists in (ansi bo)($path_name)(ansi reset)" }
    } else {
        if not $quiet { print $"(ansi bl)(ansi cb)[LOG](ansi reset) (ansi u)($path_value)(ansi reset) appended to (ansi bo)($path_name)(ansi reset)" }
    }
    $exists
}

def safe_expand_env [path_name: string, path_value: string] {
    let paths = $env | get $path_name
    let exists = ($path_value | path expand) in $paths
    if not $exists { $path_value } else { null }
}

# vim: ft=nu
