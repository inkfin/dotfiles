# -*- zsh -*-
# vi: ft=zsh

# ======================================
#  helper.zsh
# ======================================
#   Some zsh utilities
# ======================================


# ==== Define Variables ====

is_command() {
  command -v "$1" >/dev/null 2>&1
}

source_if_readable() {
  local file="$1"
  [[ -r "$file" ]] && source "$file"
}

source_once_if_readable() {
  local file="$1"
  local guard="__source_once_${file//[^A-Za-z0-9_]/_}"

  [[ -n "${(P)guard}" ]] && return 0
  [[ -r "$file" ]] || return 0

  typeset -g "$guard=1"
  source "$file"
}

_valid_identifier() {
  [[ "$1" =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]]
}

# Export a variable only if it is not already defined.
export_if_undefined() {
  local var="$1"
  local value="$2"

  _valid_identifier "$var" || return 1

  if [[ -z "${(P)var}" ]]; then
    typeset -gx "$var=$value"
  fi
}


# Detect whether we are running inside Windows Subsystem for Linux (WSL).
# Returns 0 on WSL, 1 elsewhere, so the result is safe to use on any machine:
#   if is_wsl; then ...; fi
is_wsl() {
  [[ $(uname -r 2>/dev/null) == *icrosoft* ]]
}


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

  _valid_identifier "$var" || return 1

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
    if [[ "$silent" != "true" ]]; then
      echo "Token already exists in '$var': $token"
    fi
    return 0
  fi

  # Construct the new value
  if [[ -z "$cur" ]]; then
    typeset -gx "$var=$token"
  else
    if [[ "$mode" == "prepend" ]]; then
      typeset -gx "$var=$token$sep$cur"
    else
      typeset -gx "$var=$cur$sep$token"
    fi
  fi

  if [[ "$silent" != "true" ]]; then
    echo "Updated $var: ${(P)var}"
  fi
  return 0
}

var_token_remove() {
  local var="$1"
  local token="$2"
  local sep="$3"
  local silent="${4:-true}"

  # Current value
  local cur="${(P)var}"
  _valid_identifier "$var" || return 1

  if [[ -z "$cur" ]]; then
    if [[ "$silent" != "true" ]]; then
      echo "'$var' is empty."
    fi
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
    typeset -gx "$var=${(j/:/)out}"
  else
    typeset -gx "$var=${(j: :)out}"
  fi

  if [[ "$silent" != "true" ]]; then
    echo "Updated $var: ${(P)var}"
  fi
  return 0
}

# PATH-like variables (colon-separated). PATH is special-cased to use zsh's
# built-in `path` array binding so dedup and filtering stay array-native;
# any other colon-separated variable falls back to the generic string logic.
append_to_path()   { _path_op "$1" "$2" append  "${3:-true}"; }
prepend_to_path()  { _path_op "$1" "$2" prepend "${3:-true}"; }
remove_from_path() { _path_op "$1" "$2" remove "${3:-true}"; }

_path_op() {
  local var="$1" token="$2" mode="$3" silent="$4"
  _valid_identifier "$var" || return 1
  [[ -n "$token" ]] || return 0

  # PATH is a tied array (typeset -T PATH path :). Work on the array so
  # dedup / filtering stay array-native.
  if [[ "$var" == "PATH" ]]; then
    if [[ "$mode" == "remove" ]]; then
      path=(${path:#$token})
    else
      path=(${(u)path})                      # dedup existing entries
      if (( ${path[(Ie)$token]} )); then     # token already present
        return 0
      fi
      if [[ "$mode" == "prepend" ]]; then
        path=("$token" $path)
      else
        path+=("$token")
      fi
    fi
    return 0
  fi

  # Generic colon-separated variables: string logic.
  case "$mode" in
    remove) var_token_remove "$var" "$token" ":" "$silent" ;;
    *)      var_token_add    "$var" "$token" ":" "$mode"  "$silent" ;;
  esac
}

# Thin wrapper for flag-like variables (space-separated)
append_to_flag()   { var_token_add "$1" "$2" " " append  "${3:-true}"; }
remove_from_flag() { var_token_remove "$1" "$2" " "      "${3:-true}"; }
