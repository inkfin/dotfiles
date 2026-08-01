# Utilities functions

def path_contains [new_path: string, quiet?: bool = true] {
    let exists = ($new_path | path expand) in $env.PATH
    if $exists {
        if not $quiet {
            print $"(ansi blue_bold)[LOG](ansi reset) (ansi u)($new_path)(ansi reset) already in PATH"
        }
    } else {
        if not $quiet {
            print $"(ansi blue_bold)[LOG](ansi reset) (ansi u)($new_path)(ansi reset) appended to PATH"
        }
    }
    $exists
}

def safe_append_path --env [path: string] {
    let expanded = ($path | path expand)
    if ($expanded | path exists) and ($expanded not-in $env.PATH) {
        $env.PATH = ($env.PATH | append $expanded)
    }
}

def safe_prepend_path --env [path: string] {
    let expanded = ($path | path expand)
    if ($expanded | path exists) and ($expanded not-in $env.PATH) {
        $env.PATH = ($env.PATH | prepend $expanded)
    }
}

def env_contains [path_name: string, path_value: string, quiet?: bool = true] {
    let paths = $env | get $path_name
    let expanded = ($path_value | path expand)
    let exists = $expanded in $paths
    if $exists {
        if not $quiet {
            print $"(ansi blue_bold)[LOG](ansi reset) (ansi u)($path_value)(ansi reset) already in (ansi bold)($path_name)(ansi reset)"
        }
    } else {
        if not $quiet {
            print $"(ansi blue_bold)[LOG](ansi reset) (ansi u)($path_value)(ansi reset) appended to (ansi bold)($path_name)(ansi reset)"
        }
    }
    $exists
}

def safe_append_env --env [path_name: string, path_value: string] {
    let expanded = ($path_value | path expand)
    if $expanded not-in ($env | get $path_name) {
        let new_val = ($env | get $path_name | append $expanded)
        load-env { $path_name: $new_val }
    }
}

# vim: ft=nu
