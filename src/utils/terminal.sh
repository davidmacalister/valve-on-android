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
export PURPLE="\033[35m"
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
        if [[ "$char" == $'\x7f' || "$char" == $'\x08' ]]; then
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

# Returns game name formatted with exact ANSI color palette
format_game_name_colored() {
    local name="$1"
    case "$name" in
        *"Day of Defeat"*)  echo -e "${GREEN}Day${RESET} of ${RED}Defeat:${RESET} Source" ;;
        *"Counter-Strike"*) echo -e "${name}" ;;
        *"Blue Shift"*)     echo -e "${BLUE}${name}${RESET}" ;;
        *"Opposing Force"*) echo -e "${GREEN}${name}${RESET}" ;;
        *"Half-Life"*)      echo -e "${ORANGE}${name}${RESET}" ;;
        *"Team Fortress"*)  echo -e "${YELLOW}${name}${RESET}" ;;
        *"Portal"*)         echo -e "${CYAN}${name}${RESET}" ;;
        *)                  echo -e "${name}" ;;
    esac
}

# Helper to read arrow keys or navigation keys
read_key() {
    local key=""
    IFS= read -rsn1 key 2>/dev/null
    if [[ "$key" == $'\x1b' ]]; then
        local rest=""
        read -rsn2 -t 0.1 rest 2>/dev/null
        key="${key}${rest}"
    fi
    case "$key" in
        $'\x1b[A'|'w'|'W') echo "UP" ;;
        $'\x1b[B'|'s'|'S') echo "DOWN" ;;
        $'\x1b[C'|'d'|'D'|''|$'\x0a'|$'\x0d') echo "ENTER" ;;
        ' ')               echo "SPACE" ;;
        'b'|'B'|$'\x1b[D'|'a'|'A') echo "BACK" ;;
        *)                 echo "$key" ;;
    esac
}

# Animated Braille Spinner Executor
run_step_with_spinner() {
    local step_label="$1"
    local success_label="$2"
    shift 2

    # Exact requested Braille spinner clockwise sequence: ⠋ → ⠙ → ⠹ → ⠸ → ⠼ → ⠴ → ⠦ → ⠧ → ⠇ → ⠏
    local -a frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local frame_idx=0

    # Hide cursor
    echo -ne "\033[?25l"

    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        for (( i=0; i<${#frames[@]}; i++ )); do
            echo -ne "\033[1G\033[K\033[?25l${BLUE}${frames[frame_idx]}${RESET} ${step_label}"
            frame_idx=$(( (frame_idx + 1) % ${#frames[@]} ))
            sleep 0.08
        done
        echo -ne "\033[1G\033[K${GREEN}✓ ${success_label}${RESET}"
        sleep 0.8
        echo -ne "\033[?25h"
        return 0
    fi

    local log_file
    log_file="$(mktemp --tmpdir step_out.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "/tmp/step_out.log")"
    register_temp_file "$log_file"

    "$@" > "$log_file" 2>&1 &
    local cmd_pid=$!

    while kill -0 "$cmd_pid" 2>/dev/null; do
        echo -ne "\033[1G\033[K\033[?25l${BLUE}${frames[frame_idx]}${RESET} ${step_label}"
        frame_idx=$(( (frame_idx + 1) % ${#frames[@]} ))
        sleep 0.08
    done

    wait "$cmd_pid"
    local status=$?

    if [[ $status -eq 0 ]]; then
        echo -ne "\033[1G\033[K${GREEN}✓ ${success_label}${RESET}"
        sleep 0.8
    else
        echo -ne "\033[1G\033[K${RED}✗ Ocorreu um erro.${RESET}\n"
        if [[ -s "$log_file" ]]; then
            tail -n 4 "$log_file" | while read -r line; do
                echo -e "  ${RED}${line}${RESET}"
            done
        fi
        save_error_log "$step_label" "$status" "$log_file" "$@"
        sleep 2.5
    fi

    echo -ne "\033[?25h"
    return $status
}

# Function to write persistent timestamped error logs for failed operations
save_error_log() {
    local step_label="$1"
    local exit_status="$2"
    local temp_log_file="$3"
    shift 3
    local cmd_str="$*"

    local log_dir="${HOME}/.config/valve-on-android/logs"
    mkdir -p "$log_dir" 2>/dev/null || log_dir="${SCRIPT_DIR}/logs"
    mkdir -p "$log_dir" 2>/dev/null || log_dir="/tmp"

    local timestamp
    timestamp="$(date '+%Y%m%d_%H%M%S')"
    local error_log_path="${log_dir}/error_${timestamp}.log"

    {
        echo "=========================================="
        echo "VALVE ON ANDROID - ERROR LOG"
        echo "=========================================="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Step: $step_label"
        echo "Command: $cmd_str"
        echo "Exit Status: $exit_status"
        echo "------------------------------------------"
        echo "OUTPUT & TRACEBACK:"
        if [[ -s "$temp_log_file" ]]; then
            cat "$temp_log_file"
        else
            echo "(No output captured)"
        fi
        echo "=========================================="
    } > "$error_log_path" 2>/dev/null

    echo
    echo -e "  ${YELLOW}${LANG_ERROR_LOG_SAVED:-Log de erro salvo em:}${RESET} ${BOLD}${error_log_path}${RESET}"
}


