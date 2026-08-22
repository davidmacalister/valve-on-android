# ==========================================
# Terminal Utilities & Formatting
# ==========================================

# ANSI Color Definitions
export BOLD="\033[1m"
export RESET="\033[0m"
export YELLOW="\033[33m"
export ORANGE="\033[38;5;208m"
export BLUE="\033[34m"
export CYAN="\033[96m"
export GREEN="\033[32m"
export RED="\033[31m"
export ITALIC="\033[3m"

# Track temporary files for automatic cleanup
TEMP_FILES=()

register_temp_file() {
    TEMP_FILES+=("$1")
}

cleanup_temp_files() {
    for tmp_file in "${TEMP_FILES[@]}"; do
        if [[ -n "$tmp_file" && -e "$tmp_file" ]]; then
            rm -rf "$tmp_file" 2>/dev/null || true
        fi
    done
}

# Trap signals for graceful cleanup
trap cleanup_temp_files EXIT INT TERM

# Masked password input reader
read_masked_password() {
    local prompt_msg="$1"
    local secret=""
    local char=""

    echo -n "$prompt_msg " >&2
    while IFS= read -r -s -n1 char; do
        [[ -z "$char" ]] && echo >&2 && break
        if [[ "$char" == $'\x7f' ]]; then
            if [[ ${#secret} -gt 0 ]]; then
                secret="${secret%?}"
                echo -ne "\b \b" >&2
            fi
        else
            secret+="$char"
            echo -n "*" >&2
        fi
    done
    echo "$secret"
}
