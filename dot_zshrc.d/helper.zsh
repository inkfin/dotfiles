# -*- zsh -*-
# vi: ft=zsh

# ======================================
#  helper.zsh
# ======================================
#   Some zsh utilities
# ======================================


# ==== Path Operations ====
# Generic helper to add/remove a token (path entry or flag) to/from a delimited variable.
# Examples:
#   var_token_add PATH "/usr/local/bin" ":" append
#   var_token_add PATH "/opt/bin" ":" prepend
#   var_token_remove PATH "/opt/bin" ":"
#   var_token_add CXXFLAGS "-O3" " " append

var_token_add() {
  local var="$1"
  local token="$2"
  local sep="$3"              # ":" for PATH-like vars, " " for flag vars
  local mode="${4:-append}"   # append | prepend
  local silent="${5:-true}"

  # Current value of the variable (indirect expansion)
  local cur="${(P)var}"
  local -a parts
  local exists=false

  # Split the current value into tokens
  if [[ -n "$cur" ]]; then
    if [[ "$sep" == ":" ]]; then
      parts=("${(s/:/)cur}")
    else
      # Word-splitting for space-separated flags
      parts=(${=cur})
    fi

    # Check if the token already exists
    local p
    for p in "${parts[@]}"; do
      if [[ "$p" == "$token" ]]; then
        exists=true
        break
      fi
    done
  fi

  # Do nothing if the token is already present
  if [[ "$exists" == true ]]; then
    [[ "$silent" != "true" ]] && echo "Token already exists in '$var': $token"
    return 0
  fi

  # Construct the new value
  if [[ -z "$cur" ]]; then
    eval "export $var=\$token"
  else
    if [[ "$mode" == "prepend" ]]; then
      eval "export $var=\$token\$sep\${(P)var}"
    else
      eval "export $var=\${(P)var}\$sep\$token"
    fi
  fi

  [[ "$silent" != "true" ]] && echo "Updated $var: ${(P)var}"
}

var_token_remove() {
  local var="$1"
  local token="$2"
  local sep="$3"
  local silent="${4:-true}"

  # Current value
  local cur="${(P)var}"
  if [[ -z "$cur" ]]; then
    [[ "$silent" != "true" ]] && echo "'$var' is empty."
    return 0
  fi

  # Split into tokens
  local -a parts out
  if [[ "$sep" == ":" ]]; then
    parts=("${(s/:/)cur}")
  else
    parts=(${=cur})
  fi

  # Rebuild without the target token
  local p
  for p in "${parts[@]}"; do
    [[ "$p" == "$token" ]] && continue
    out+=("$p")
  done

  # Join back
  if [[ "$sep" == ":" ]]; then
    eval "export $var='${(j/:/)out}'"
  else
    eval "export $var='${(j: :)out}'"
  fi

  [[ "$silent" != "true" ]] && echo "Updated $var: ${(P)var}"
}

# Thin wrappers for PATH-like variables
append_to_path()   { var_token_add "$1" "$2" ":" append  "${3:-true}"; }
prepend_to_path()  { var_token_add "$1" "$2" ":" prepend "${3:-true}"; }
remove_from_path() { var_token_remove "$1" "$2" ":"      "${3:-true}"; }

# Thin wrapper for flag-like variables (space-separated)
append_to_flag()   { var_token_add "$1" "$2" " " append  "${3:-true}"; }
remove_from_flag() { var_token_remove "$1" "$2" " "      "${3:-true}"; }
