# -*- zsh -*-
# vi: ft=zsh

# ======================================
#  helper.zsh
# ======================================
#   Some zsh utilities
# ======================================


# ==== Helper Functions ====

append_to_path() {
    local path_var="$1"
    local new_dir="$2"
    local silent="${3:-true}"

    # Ensure that the path variable exists
    if [[ -z "${(P)path_var}" ]]; then
        eval "export $path_var='$new_dir'"
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' has been set as the initial value of '$path_var'."
    elif [[ ":${(P)path_var}:" != *":$new_dir:"* ]]; then
        eval "export $path_var=\${$path_var}:$new_dir"
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' has been appended to '${(P)path_var}'."
    else
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' is already in '${(P)path_var}'."
    fi

    [[ "$silent" != "true" ]] && echo "Updated path: ${(P)path_var}"
}

prepend_to_path() {
    local path_var="$1"
    local new_dir="$2"
    local silent="${3:-true}"

    # Ensure that the path variable exists
    if [[ -z "${(P)path_var}" ]]; then
        eval "export $path_var='$new_dir'"
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' has been set as the initial value of '$path_var'."
    elif [[ ":${(P)path_var}:" != *":$new_dir:"* ]]; then
        eval "export $path_var=$new_dir:\${$path_var}"
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' has been prepended to '${(P)path_var}'."
    else
        [[ "$silent" != "true" ]] && echo "Directory '$new_dir' is already in '${(P)path_var}'."
    fi

    [[ "$silent" != "true" ]] && echo "Updated path: ${(P)path_var}"
}

remove_from_path() {
    local path_var="$1"
    local remove_dir="$2"
    local silent="${3:-true}"

    if [[ -z "${(P)path_var}" ]]; then
        [[ "$silent" != "true" ]] && echo "The path variable '$path_var' is empty or does not exist."
        return
    fi

    local new_path
    new_path=$(echo "${(P)path_var}" | awk -v RS=':' -v ORS=':' -v remove_dir="$remove_dir" '$0 != remove_dir {print}' | sed 's/:$//')

    eval "export $path_var='$new_path'"

    if [[ "$silent" != "true" ]]; then
        if [[ "$new_path" == *"$remove_dir"* ]]; then
            echo "Failed to remove '$remove_dir' from '$path_var'."
        else
            echo "Directory '$remove_dir' has been removed from '$path_var'."
            echo "Updated path: ${(P)path_var}"
        fi
    fi
}

append_to_flag() {
    local flag_var="$1"
    local new_flag="$2"
    local silent="${3:-true}"

    # Ensure that the flag variable exists
    if [[ -z "${(P)flag_var}" ]]; then
        eval "$flag_var='$new_flag'"
        export $flag_var
        [[ "$silent" != "true" ]] && echo "Flag '$new_flag' has been set as the initial value of '$flag_var'."
    elif [[ " ${${(P)flag_var}} " != *" $new_flag "* ]]; then
        eval "$flag_var='${(P)flag_var} $new_flag'"
        export $flag_var
        [[ "$silent" != "true" ]] && echo "Flag '$new_flag' has been appended to '${(P)flag_var}'."
    else
        [[ "$silent" != "true" ]] && echo "Flag '$new_flag' is already in '${(P)flag_var}'."
    fi

    [[ "$silent" != "true" ]] && echo "Updated flags: ${(P)flag_var}"
}
