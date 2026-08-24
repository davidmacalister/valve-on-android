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

is_dir_nonempty() {
    local d="$1"
    [[ -d "$d" ]] && [[ -n "$(ls -A "$d" 2>/dev/null)" ]]
}

is_goldsrc_variant_installed() {
    local cat_idx="$1"
    local variant="$2" # "25th" or "pre25th"
    local base_dir="${SET_DIR}xash"
    [[ "$variant" == "pre25th" ]] && base_dir="${SET_DIR}xash_old"

    case "$cat_idx" in
        0) # Half-Life
            is_dir_nonempty "${base_dir}/valve" || is_dir_nonempty "${base_dir}"
            ;;
        1) # Blue Shift
            is_dir_nonempty "${base_dir}/bshift"
            ;;
        2) # Opposing Force
            is_dir_nonempty "${base_dir}/gearbox"
            ;;
        7) # Counter-Strike
            is_dir_nonempty "${base_dir}/cstrike"
            ;;
        10) # Team Fortress Classic
            is_dir_nonempty "${base_dir}/tfc"
            ;;
        *)
            return 1
            ;;
    esac
}

is_source_game_installed() {
    local cat_idx="$1"
    case "$cat_idx" in
        3) # HL2
            is_dir_nonempty "${SET_DIR}srceng/hl2" || is_dir_nonempty "${SET_DIR}srceng"
            ;;
        4) # Ep1
            is_dir_nonempty "${SET_DIR}srceng/episodic"
            ;;
        5) # Ep2
            is_dir_nonempty "${SET_DIR}srceng/ep2"
            ;;
        6) # HL:Source
            is_dir_nonempty "${SET_DIR}srceng/hl1"
            ;;
        8) # CS:Source
            is_dir_nonempty "${SET_DIR}srceng/cstrike" || is_dir_nonempty "${SET_DIR}cstrike"
            ;;
        9) # DoD:Source
            is_dir_nonempty "${SET_DIR}srceng/dod" || is_dir_nonempty "${SET_DIR}dod"
            ;;
        11) # Portal
            is_dir_nonempty "${SET_DIR}srceng/portal" || is_dir_nonempty "${SET_DIR}portal"
            ;;
        *)
            return 1
            ;;
    esac
}

is_game_fully_installed_locally() {
    local cat_idx="$1"
    case "$cat_idx" in
        0|1|2|7|10) # GoldSrc games: return 0 ONLY if BOTH 25th AND pre25th are installed
            is_goldsrc_variant_installed "$cat_idx" "25th" && is_goldsrc_variant_installed "$cat_idx" "pre25th"
            ;;
        *) # Source games: return 0 if game dir is installed
            is_source_game_installed "$cat_idx"
            ;;
    esac
}

is_game_any_installed_locally() {
    local cat_idx="$1"
    case "$cat_idx" in
        0|1|2|7|10) # GoldSrc games: return 0 if EITHER 25th OR pre25th is installed
            is_goldsrc_variant_installed "$cat_idx" "25th" || is_goldsrc_variant_installed "$cat_idx" "pre25th"
            ;;
        *) # Source games
            is_source_game_installed "$cat_idx"
            ;;
    esac
}

get_game_local_directories() {
    local cat_idx="$1"
    local -a dirs=()

    case "$cat_idx" in
        0)
            is_dir_nonempty "${SET_DIR}xash/valve" && dirs+=("${SET_DIR}xash/valve")
            is_dir_nonempty "${SET_DIR}xash_old/valve" && dirs+=("${SET_DIR}xash_old/valve")
            ;;
        1)
            is_dir_nonempty "${SET_DIR}xash/bshift" && dirs+=("${SET_DIR}xash/bshift")
            is_dir_nonempty "${SET_DIR}xash_old/bshift" && dirs+=("${SET_DIR}xash_old/bshift")
            ;;
        2)
            is_dir_nonempty "${SET_DIR}xash/gearbox" && dirs+=("${SET_DIR}xash/gearbox")
            is_dir_nonempty "${SET_DIR}xash_old/gearbox" && dirs+=("${SET_DIR}xash_old/gearbox")
            ;;
        3)
            is_dir_nonempty "${SET_DIR}srceng/hl2" && dirs+=("${SET_DIR}srceng/hl2")
            ;;
        4)
            is_dir_nonempty "${SET_DIR}srceng/episodic" && dirs+=("${SET_DIR}srceng/episodic")
            ;;
        5)
            is_dir_nonempty "${SET_DIR}srceng/ep2" && dirs+=("${SET_DIR}srceng/ep2")
            ;;
        6)
            is_dir_nonempty "${SET_DIR}srceng/hl1" && dirs+=("${SET_DIR}srceng/hl1")
            ;;
        7)
            is_dir_nonempty "${SET_DIR}xash/cstrike" && dirs+=("${SET_DIR}xash/cstrike")
            is_dir_nonempty "${SET_DIR}xash_old/cstrike" && dirs+=("${SET_DIR}xash_old/cstrike")
            ;;
        8)
            is_dir_nonempty "${SET_DIR}srceng/cstrike" && dirs+=("${SET_DIR}srceng/cstrike")
            is_dir_nonempty "${SET_DIR}cstrike" && dirs+=("${SET_DIR}cstrike")
            ;;
        9)
            is_dir_nonempty "${SET_DIR}srceng/dod" && dirs+=("${SET_DIR}srceng/dod")
            is_dir_nonempty "${SET_DIR}dod" && dirs+=("${SET_DIR}dod")
            ;;
        10)
            is_dir_nonempty "${SET_DIR}xash/tfc" && dirs+=("${SET_DIR}xash/tfc")
            is_dir_nonempty "${SET_DIR}xash_old/tfc" && dirs+=("${SET_DIR}xash_old/tfc")
            ;;
        11)
            is_dir_nonempty "${SET_DIR}srceng/portal" && dirs+=("${SET_DIR}srceng/portal")
            is_dir_nonempty "${SET_DIR}portal" && dirs+=("${SET_DIR}portal")
            ;;
    esac

    echo "${dirs[@]:-}"
}

get_installed_games_count() {
    load_installed_games_list
    echo "${#INSTALLED_GAMES_NAMES[@]}"
}

load_installed_games_list() {
    INSTALLED_GAMES_ARGS=()
    INSTALLED_GAMES_APPIDS=()
    INSTALLED_GAMES_DEPOTS=()
    INSTALLED_GAMES_NAMES=()
    INSTALLED_GAMES_MODES=()
    INSTALLED_GAMES_OFF_LANGS=()
    INSTALLED_GAMES_COMM_LANGS=()
    INSTALLED_GAMES_CATALOG_INDICES=()

    local -a catalog_names=(
        "Half-Life"
        "Half-Life: Blue Shift"
        "Half-Life: Opposing Force"
        "Half-Life 2"
        "Half-Life 2: Episode One"
        "Half-Life 2: Episode Two"
        "Half-Life: Source"
        "Counter-Strike"
        "Counter-Strike: Source"
        "Day of Defeat: Source"
        "Team Fortress Classic"
        "Portal"
    )

    local -a catalog_appids=(70 130 50 220 220 220 280 10 240 300 20 400)
    local -a catalog_depots=(1 130 51 221 389 420 280 11 241 301 21 401)
    local -a catalog_args=(
        "-app 70 -depot 1 -dir xash"
        "-app 130 -depot 130 -dir xash"
        "-app 50 -depot 51 -dir xash"
        "-branch steam_legacy -app 220 -depot 221 -dir srceng"
        "-branch steam_legacy -app 220 -depot 389 -dir srceng"
        "-branch steam_legacy -app 220 -depot 420 -dir srceng"
        "-app 280 -depot 280 -dir srceng"
        "-app 10 -depot 11 -dir xash"
        "-branch previous_build -app 240 -depot 241 -dir srceng"
        "-branch previous_build -app 300 -depot 301 -dir srceng"
        "-app 20 -depot 21 -dir xash"
        "-app 400 -depot 401 -dir srceng"
    )

    for (( i=0; i<${#catalog_names[@]}; i++ )); do
        if is_game_any_installed_locally "$i"; then
            INSTALLED_GAMES_NAMES+=("${catalog_names[$i]}")
            INSTALLED_GAMES_APPIDS+=("${catalog_appids[$i]}")
            INSTALLED_GAMES_DEPOTS+=("${catalog_depots[$i]}")
            INSTALLED_GAMES_ARGS+=("${catalog_args[$i]}")
            INSTALLED_GAMES_MODES+=("")
            INSTALLED_GAMES_OFF_LANGS+=("")
            INSTALLED_GAMES_COMM_LANGS+=("")
            INSTALLED_GAMES_CATALOG_INDICES+=("$i")
        fi
    done
}
