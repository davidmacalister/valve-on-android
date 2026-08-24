# ==========================================
# Installation Log & History Management
# ==========================================

get_installation_log_path() {
    local primary="${HOME}/.config/valve-on-android/installed_games.conf"
    local secondary="${HOME}/.valve_on_android_installed_games"
    local fallback="/tmp/valve_on_android_installed_games"
    local primary_dir="$(dirname "$primary")"

    if mkdir -p "$primary_dir" 2>/dev/null && touch "$primary" 2>/dev/null; then
        echo "$primary"
    elif touch "$secondary" 2>/dev/null; then
        echo "$secondary"
    else
        echo "$fallback"
    fi
}

record_game_installation() {
    local game_args="$1"
    local appid="$2"
    local depot="$3"
    local game_name="$4"
    local trans_mode="$5"
    local off_lang="$6"
    local comm_lang="$7"

    local log_file
    log_file="$(get_installation_log_path)"
    local config_dir
    config_dir="$(dirname "$log_file")"

    mkdir -p "$config_dir" 2>/dev/null || true

    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    local tmp_file
    tmp_file="$(mktemp --tmpdir installed_tmp.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "/tmp/installed_tmp.$$")"

    if [[ -f "$log_file" ]]; then
        grep -v -F "ARGS=$game_args|" "$log_file" > "$tmp_file" 2>/dev/null || true
    fi

    echo "ARGS=$game_args|APPID=$appid|DEPOT=$depot|NAME=$game_name|MODE=$trans_mode|OFF_LANG=$off_lang|COMM_LANG=$comm_lang|TIME=$timestamp" >> "$tmp_file"
    mv -f "$tmp_file" "$log_file" 2>/dev/null || cp -f "$tmp_file" "$log_file" 2>/dev/null || true
    rm -f "$tmp_file" 2>/dev/null || true
}

get_installed_games_count() {
    local log_file
    log_file="$(get_installation_log_path)"
    if [[ -f "$log_file" && -s "$log_file" ]]; then
        wc -l < "$log_file" | tr -d ' '
    else
        echo "0"
    fi
}

load_installed_games_list() {
    local log_file
    log_file="$(get_installation_log_path)"

    INSTALLED_GAMES_ARGS=()
    INSTALLED_GAMES_APPIDS=()
    INSTALLED_GAMES_DEPOTS=()
    INSTALLED_GAMES_NAMES=()
    INSTALLED_GAMES_MODES=()
    INSTALLED_GAMES_OFF_LANGS=()
    INSTALLED_GAMES_COMM_LANGS=()

    if [[ -f "$log_file" && -s "$log_file" ]]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            [[ -z "$line" ]] && continue

            local ARGS="" APPID="" DEPOT="" NAME="" MODE="" OFF_LANG="" COMM_LANG=""

            IFS='|' read -ra fields <<< "$line"
            for field in "${fields[@]}"; do
                case "$field" in
                    ARGS=*) ARGS="${field#ARGS=}" ;;
                    APPID=*) APPID="${field#APPID=}" ;;
                    DEPOT=*) DEPOT="${field#DEPOT=}" ;;
                    NAME=*) NAME="${field#NAME=}" ;;
                    MODE=*) MODE="${field#MODE=}" ;;
                    OFF_LANG=*) OFF_LANG="${field#OFF_LANG=}" ;;
                    COMM_LANG=*) COMM_LANG="${field#COMM_LANG=}" ;;
                esac
            done

            if [[ -n "$ARGS" ]]; then
                INSTALLED_GAMES_ARGS+=("$ARGS")
                INSTALLED_GAMES_APPIDS+=("${APPID:-}")
                INSTALLED_GAMES_DEPOTS+=("${DEPOT:-}")
                INSTALLED_GAMES_NAMES+=("${NAME:-Unknown Game}")
                INSTALLED_GAMES_MODES+=("${MODE:-}")
                INSTALLED_GAMES_OFF_LANGS+=("${OFF_LANG:-}")
                INSTALLED_GAMES_COMM_LANGS+=("${COMM_LANG:-}")
            fi
        done < "$log_file"
    fi
}
