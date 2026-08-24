# ==========================================
# Game & Package Download Execution Engine
# ==========================================

get_app_id_from_args() {
    local -a tokens=( $1 )
    for (( i=0; i<${#tokens[@]}; i++ )); do
        if [[ "${tokens[$i]}" == "-app" ]]; then
            echo "${tokens[$((i+1))]}"
            return 0
        fi
    done
}

get_depot_id_from_args() {
    local -a tokens=( $1 )
    for (( i=0; i<${#tokens[@]}; i++ )); do
        if [[ "${tokens[$i]}" == "-depot" ]]; then
            echo "${tokens[$((i+1))]}"
            return 0
        fi
    done
}

mask_password_in_cmd() {
    local -a cmd_copy=( "$@" )
    for (( i=0; i<${#cmd_copy[@]}; i++ )); do
        if [[ "${cmd_copy[$i]}" == "-password" && $((i+1)) -lt ${#cmd_copy[@]} ]]; then
            cmd_copy[$((i+1))]="********"
        fi
    done
    echo "${cmd_copy[*]}"
}

get_dir_from_args() {
    local -a tokens=( $1 )
    for (( i=0; i<${#tokens[@]}; i++ )); do
        if [[ "${tokens[$i]}" == "-dir" ]]; then
            echo "${tokens[$((i+1))]}"
            return 0
        fi
    done
}

run_official_language_download() {
    local appid="$1"
    local depot="$2"
    local username="$3"
    local password="$4"
    local selected_lang="$5"

    local depot_id=""
    local target_dir=""
    case "$appid" in
        220)
            if [[ $depot == 221 ]]; then
                depot_id="${HL2_LANG_DEPOTS[$selected_lang]:-}"
                target_dir="srceng"
            elif [[ $depot == 389 || $depot == 380 ]]; then
                depot_id="${HL2_EP1_LANG_DEPOTS[$selected_lang]:-}"
                target_dir="srceng"
            elif [[ $depot == 420 ]]; then
                depot_id="${HL2_EP2_LANG_DEPOTS[$selected_lang]:-}"
                target_dir="srceng"
            fi
            ;;
        240) depot_id="${CSS_LANG_DEPOTS[$selected_lang]:-}"; target_dir="srceng" ;;
        400) depot_id="${PORTAL_LANG_DEPOTS[$selected_lang]:-}"; target_dir="srceng" ;;
        70)  depot_id="${HL_LANG_DEPOTS[$selected_lang]:-}"; target_dir="xash" ;;
        130) depot_id="${HLBS_LANG_DEPOTS[$selected_lang]:-}"; target_dir="xash" ;;
        50)  depot_id="${HLOF_LANG_DEPOTS[$selected_lang]:-}"; target_dir="xash" ;;
        10)  depot_id="${CS_LANG_DEPOTS[$selected_lang]:-}"; target_dir="xash" ;;
        20)  depot_id="${TFC_LANG_DEPOTS[$selected_lang]:-}"; target_dir="xash" ;;
    esac

    if [[ -n "$depot_id" ]]; then
        echo -e "${BOLD}${GREEN}${LANG_DOWNLOADING_LANG_PACK}${RESET} ${LANG_DISPLAY_NAMES[$selected_lang]:-$selected_lang}"
        local -a lang_cmd=(
            depotdownloader
            -username "$username"
            -password "$password"
            -remember-password
            -validate
            -app "$appid"
            -depot "$depot_id"
            -dir "$target_dir"
        )

        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            echo -e "${YELLOW}[DRY RUN] Simulated command:${RESET} $(mask_password_in_cmd "${lang_cmd[@]}")"
            return 0
        fi

        "${lang_cmd[@]}" || {
            echo -e "${RED}${LANG_COMMANDS_ABOVE}${RESET}"
            return 1
        }
    fi
}

run_community_language_download() {
    local appid="$1"
    local depot="$2"
    local game_name="$3"
    local selected_comm_lang="$4"
    local target_dir_name="$5"

    local key_dep="${appid}:${depot},${selected_comm_lang}"
    local key_app="${appid},${selected_comm_lang}"

    local url="${COMMUNITY_URLS[$key_dep]:-${COMMUNITY_URLS[$key_app]:-}}"
    local outfile="${COMMUNITY_OUTFILES[$key_dep]:-${COMMUNITY_OUTFILES[$key_app]:-${appid}_${selected_comm_lang}.zip}}"
    local outdir="${COMMUNITY_OUTDIRS[$key_dep]:-${COMMUNITY_OUTDIRS[$key_app]:-${PWD}/downloads}}"

    if [[ -n "$target_dir_name" && "$outdir" == *"/xash"* && "$target_dir_name" == "xash_old" ]]; then
        outdir="${outdir/xash/xash_old}"
    fi

    local display_label="${COMMUNITY_LANG_DISPLAY[$selected_comm_lang]:-$selected_comm_lang}"

    if [[ -n "$url" ]]; then
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            echo -e "${YELLOW}[DRY RUN] Simulated Community Pack Download:${RESET}"
            echo -e "  Label: ${display_label}"
            echo -e "  URL: ${url}"
            echo -e "  Target Path: ${outdir}/${outfile}"
            return 0
        fi
        download_and_extract_community_pack "$url" "$outdir" "$outfile" "$display_label"
    else
        echo -e "${YELLOW}${LANG_NO_COMMUNITY_PACK} ${game_name} (${display_label})${RESET}"
    fi
}

execute_downloads() {
    local username="$1"
    local password="$2"

    for game_args in "${SELECTED_GAME_ARGS[@]}"; do
        local appid
        local depot
        local game_name
        local target_dir_name

        appid="$(get_app_id_from_args "$game_args")"
        depot="$(get_depot_id_from_args "$game_args")"
        game_name="$(get_game_name "$appid" "$depot")"
        target_dir_name="$(get_dir_from_args "$game_args")"

        clear
        echo -e "${BOLD}${GREEN}${LANG_DOWNLOADING}${RESET} ${game_name}"

        # Convert space-separated string arguments into array safely (no eval)
        local -a arg_tokens=( $game_args )
        local -a full_cmd=(
            depotdownloader
            -username "$username"
            -password "$password"
            -remember-password
            -validate
            "${arg_tokens[@]}"
        )

        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            echo -e "${YELLOW}[DRY RUN] Simulated Base Game Command:${RESET}"
            echo -e "  $(mask_password_in_cmd "${full_cmd[@]}")"
        else
            "${full_cmd[@]}" || {
                echo -e "${RED}[!] ${LANG_COMMANDS_ABOVE}${RESET}"
                return 1
            }
        fi

        # Handle official language pack downloads if selected
        if [[ "$TRANSLATION_MODE" == "official" && -n "$SELECTED_OFFICIAL_LANG" ]]; then
            run_official_language_download "$appid" "$depot" "$username" "$password" "$SELECTED_OFFICIAL_LANG" || return 1
        fi

        # Handle community language pack downloads if selected
        if [[ "$TRANSLATION_MODE" == "community" && -n "$SELECTED_COMMUNITY_LANG" ]]; then
            run_community_language_download "$appid" "$depot" "$game_name" "$SELECTED_COMMUNITY_LANG" "$target_dir_name"
        fi
    done
}
