# ==========================================
# Terminal UI Menus
# ==========================================

show_initial_language_menu() {
    local choice
    while true; do
        clear
        echo
        echo -e "${BOLD}Select language:${RESET}"
        echo
        echo "1) English"
        echo "2) Português (Brasil)"
        echo "3) Русский (Russian)"
        echo "4) Spanish (Español)"
        echo "============================"
        read -p "Choice (1-4): " choice

        case "$choice" in
            1) load_language_script "english.sh" && break ;;
            2) load_language_script "brazilian.sh" && break ;;
            3) load_language_script "russian.sh" && break ;;
            4) load_language_script "spanish.sh" && break ;;
            b|B) echo "Returning..."; exit 0 ;;
            *) echo -e "\nInvalid option. Try again..."; sleep 2 ;;
        esac
    done
}

show_main_menu() {
    clear
    echo
    echo -e "${BOLD}${LANG_TITLE}${RESET}"
    echo
    echo "1) ${LANG_MAIN_OPTION_ALL}"
    echo "2) ${LANG_MAIN_OPTION_MANUAL}"
    echo -e "${RED}3) ${LANG_EXIT}${RESET}"
    echo "============================"
    read -p "${LANG_PROMPT_CHOOSE} (1-3): " MAIN_MENU_CHOICE
}

show_all_games_menu() {
    local all_option
    clear
    echo
    echo -e "${BOLD}${LANG_TITLE}${RESET}"
    echo
    echo "1) ${LANG_MAIN_OPTION_ALL}"
    echo "2) ${LANG_ALL_SOURCE}"
    echo "3) ${LANG_ALL_GOLDSRC}"
    echo
    echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
    echo "============================"
    read -p "${LANG_PROMPT_CHOOSE} (1-3): " all_option

    if [[ "$all_option" == "b" ]]; then
        return 1
    fi

    if [[ "$all_option" == "1" || "$all_option" == "3" ]]; then
        if ! show_goldsrc_version_menu; then
            return 1
        fi
    fi

    if [[ "$all_option" == "1" || "$all_option" == "2" ]]; then
        add_source_games
    fi
    return 0
}

show_goldsrc_version_menu() {
    local version_choice
    clear
    echo
    echo -e "${BOLD}${LANG_GOLDSRCVERSION_TITLE}${RESET}"
    echo
    echo "1) ${LANG_GOLDSRCVERSION_OPTION_25TH}"
    echo "2) ${LANG_GOLDSRCVERSION_OPTION_PRE25TH}"
    echo -e "${YELLOW}${LANG_WARNING_OLD_VERSION}${RESET}"
    echo "3) ${LANG_BOTH}"
    echo
    echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
    echo "============================"
    read -p "${LANG_PROMPT_CHOOSE} (1-3): " version_choice

    if [[ "$version_choice" == "b" ]]; then
        return 1
    fi

    [[ "$version_choice" == "1" || "$version_choice" == "3" ]] && add_goldsrc_25
    [[ "$version_choice" == "2" || "$version_choice" == "3" ]] && add_goldsrc_pre25
    return 0
}

show_manual_game_selection_menu() {
    while true; do
        clear
        echo
        echo -e "${BOLD}${LANG_TITLE}${RESET}"
        echo
        echo -e "${BOLD}${LANG_GAMES_TITLE_SOURCE}${RESET}"
        echo -e "${ORANGE}1) Half-Life 2${RESET}"
        echo -e "${ORANGE}2) Half-Life 2: Episode 1${RESET}"
        echo -e "${ORANGE}3) Half-Life 2: Episode 2${RESET}"
        echo -e "${ORANGE}4) Half-Life 2: Deathmatch${RESET}"
        echo -e "${ORANGE}5) Half-Life: Source${RESET}"
        echo "6) Counter-Strike: Source"
        echo "7) Day of Defeat: Source"
        echo -e "${CYAN}8) Portal${RESET}"
        echo
        echo -e "${BOLD}${LANG_GAMES_TITLE_GOLDSRC}${RESET}"
        echo -e "${ORANGE}9) Half-Life${RESET}"
        echo -e "${BLUE}10) Half-Life: Blue Shift${RESET}"
        echo -e "${GREEN}11) Half-Life: Opposing Force${RESET}"
        echo "12) Counter-Strike"
        echo -e "${YELLOW}13) Team Fortress Classic${RESET}"
        echo
        echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
        echo "============================"
        read -p "${LANG_PROMPT_CHOOSE_MORE} (1–13): " selections

        if [[ "$selections" == "b" ]]; then
            return 1
        fi

        local -a choices
        IFS=',' read -ra choices <<< "$selections"
        local -a goldsrc_choices=()

        for choice in "${choices[@]}"; do
            case "$choice" in
                1) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 221 -dir srceng") ;;
                2) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 389 -dir srceng" "-branch steam_legacy -app 220 -depot 380 -dir srceng") ;;
                3) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 420 -dir srceng") ;;
                4) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 320 -depot 321 -dir srceng") ;;
                5) SELECTED_GAME_ARGS+=("-app 280 -depot 280 -dir srceng") ;;
                6) SELECTED_GAME_ARGS+=("-branch previous_build -app 240 -depot 241 -dir srceng") ;;
                7) SELECTED_GAME_ARGS+=("-branch previous_build -app 300 -depot 301 -dir srceng") ;;
                8) SELECTED_GAME_ARGS+=("-app 400 -depot 401 -dir srceng") ;;
                9|10|11|12|13) goldsrc_choices+=("$choice") ;;
            esac
        done

        if [[ "${#goldsrc_choices[@]}" -gt 0 ]]; then
            local version_choice
            clear
            echo
            echo -e "${BOLD}${LANG_GOLDSRCVERSION_TITLE}${RESET}"
            echo
            echo "1) ${LANG_GOLDSRCVERSION_OPTION_25TH}"
            echo "2) ${LANG_GOLDSRCVERSION_OPTION_PRE25TH}"
            echo -e "${YELLOW}${LANG_WARNING_OLD_VERSION}${RESET}"
            echo "3) ${LANG_BOTH}"
            echo
            echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
            echo "============================"
            read -p "${LANG_PROMPT_CHOOSE} (1-3): " version_choice

            if [[ "$version_choice" == "b" ]]; then
                return 1
            fi

            for choice in "${goldsrc_choices[@]}"; do
                if [[ "$version_choice" == "1" || "$version_choice" == "3" ]]; then
                    case "$choice" in
                        9)  SELECTED_GAME_ARGS+=("-app 70 -depot 1 -dir xash") ;;
                        10) SELECTED_GAME_ARGS+=("-app 130 -depot 130 -dir xash") ;;
                        11) SELECTED_GAME_ARGS+=("-app 50 -depot 51 -dir xash") ;;
                        12) SELECTED_GAME_ARGS+=("-app 10 -depot 11 -dir xash") ;;
                        13) SELECTED_GAME_ARGS+=("-app 20 -depot 21 -dir xash") ;;
                    esac
                fi
                if [[ "$version_choice" == "2" || "$version_choice" == "3" ]]; then
                    case "$choice" in
                        9)  SELECTED_GAME_ARGS+=("-branch steam_legacy -app 70 -depot 1 -dir xash_old") ;;
                        10) SELECTED_GAME_ARGS+=("-app 130 -depot 130 -dir xash_old") ;;
                        11) SELECTED_GAME_ARGS+=("-app 50 -depot 51 -dir xash_old") ;;
                        12) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 10 -depot 11 -dir xash_old") ;;
                        13) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 20 -depot 21 -dir xash_old") ;;
                    esac
                fi
            done
        fi

        if [[ "${#SELECTED_GAME_ARGS[@]}" -eq 0 ]]; then
            echo -e "${RED}${LANG_NO_GAMES}${RESET}"
            sleep 2
            return 1
        fi
        break
    done
    return 0
}

show_language_pack_menu() {
    local choose_langpacks
    TRANSLATION_MODE=""
    SELECTED_OFFICIAL_LANG=""
    SELECTED_COMMUNITY_LANG=""

    while true; do
        clear
        echo
        echo -e "${BOLD}${LANG_ASK_LANGUAGE_PACKS}${RESET}"
        echo
        echo "1) ${LANG_YES}"
        echo "2) ${LANG_NO}"
        echo
        echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
        echo "============================"
        read -p "${LANG_PROMPT_CHOOSE} (1-2): " choose_langpacks

        if [[ "$choose_langpacks" == "b" ]]; then
            return 1
        fi

        case "$choose_langpacks" in
            1)
                while true; do
                    local translation_type
                    clear
                    echo
                    echo -e "${BOLD}${LANG_TRANSLATION_TYPE}${RESET}"
                    echo
                    echo "1) ${LANG_TRANSLATION_OFFICIAL}"
                    echo "2) ${LANG_TRANSLATION_COMMUNITY}"
                    echo
                    echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
                    echo "============================"
                    read -p "${LANG_PROMPT_CHOOSE} (1-2): " translation_type

                    if [[ "$translation_type" == "b" ]]; then
                        break
                    fi

                    case "$translation_type" in
                        1)
                            TRANSLATION_MODE="official"
                            local -a available_langs=()
                            for game_args in "${SELECTED_GAME_ARGS[@]}"; do
                                local appid
                                local depot
                                appid="$(get_app_id_from_args "$game_args")"
                                depot="$(get_depot_id_from_args "$game_args")"

                                case "$appid" in
                                    220)
                                        [[ $depot == 221 ]] && available_langs+=("${!HL2_LANG_DEPOTS[@]}")
                                        [[ $depot == 389 || $depot == 380 ]] && available_langs+=("${!HL2_EP1_LANG_DEPOTS[@]}")
                                        [[ $depot == 420 ]] && available_langs+=("${!HL2_EP2_LANG_DEPOTS[@]}")
                                        ;;
                                    240) available_langs+=("${!CSS_LANG_DEPOTS[@]}") ;;
                                    400) available_langs+=("${!PORTAL_LANG_DEPOTS[@]}") ;;
                                    70)  available_langs+=("${!HL_LANG_DEPOTS[@]}") ;;
                                    130) available_langs+=("${!HLBS_LANG_DEPOTS[@]}") ;;
                                    50)  available_langs+=("${!HLOF_LANG_DEPOTS[@]}") ;;
                                    10)  available_langs+=("${!CS_LANG_DEPOTS[@]}") ;;
                                    20)  available_langs+=("${!TFC_LANG_DEPOTS[@]}") ;;
                                esac
                            done

                            available_langs=($(printf "%s\n" "${available_langs[@]}" | sort -u))

                            clear
                            echo
                            echo -e "${BOLD}${LANG_SELECT_LANGUAGE_PACK}${RESET}"
                            echo
                            local i=1
                            declare -A lang_menu
                            for lang in "${available_langs[@]}"; do
                                echo "$i) ${LANG_DISPLAY_NAMES[$lang]:-$lang}"
                                lang_menu[$i]=$lang
                                ((i++))
                            done
                            echo
                            echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
                            echo "============================"
                            read -p "${LANG_PROMPT_CHOOSE} (1-$((i-1))): " lang_choice

                            if [[ "$lang_choice" == "b" ]]; then
                                break
                            elif [[ "$lang_choice" =~ ^[0-9]+$ ]] && (( lang_choice >= 1 && lang_choice <= i-1 )); then
                                SELECTED_OFFICIAL_LANG="${lang_menu[$lang_choice]}"
                                return 0
                            else
                                echo -e "\n${RED}${LANG_INVALID_OPTION}${RESET} ${LANG_TRY_AGAIN}"
                                sleep 2
                            fi
                            ;;
                        2)
                            TRANSLATION_MODE="community"
                            setup_community_translations
                            local -a community_available_langs=()

                            for game_args in "${SELECTED_GAME_ARGS[@]}"; do
                                local appid
                                local depot
                                appid="$(get_app_id_from_args "$game_args")"
                                depot="$(get_depot_id_from_args "$game_args")"

                                for lang_code in "${!COMMUNITY_LANG_DISPLAY[@]}"; do
                                    local key_dep="${appid}:${depot},${lang_code}"
                                    local key_app="${appid},${lang_code}"
                                    if [[ -n "${COMMUNITY_URLS[$key_dep]:-}" || -n "${COMMUNITY_URLS[$key_app]:-}" ]]; then
                                        if ! printf '%s\n' "${community_available_langs[@]}" | grep -qx "$lang_code"; then
                                            community_available_langs+=("$lang_code")
                                        fi
                                    fi
                                done
                            done

                            if [[ "${#community_available_langs[@]}" -eq 0 ]]; then
                                echo -e "${YELLOW}${LANG_NO_COMMUNITY_PACKS_AVAILABLE}${RESET}"
                                sleep 2
                                TRANSLATION_MODE=""
                                continue
                            fi

                            clear
                            echo
                            echo -e "${BOLD}${LANG_SELECT_LANGUAGE_PACK}${RESET}"
                            echo
                            local i=1
                            declare -A community_menu
                            for lang_code in "${community_available_langs[@]}"; do
                                echo -e "$i) ${COMMUNITY_LANG_DISPLAY[$lang_code]}"
                                community_menu[$i]=$lang_code
                                ((i++))
                            done
                            echo
                            echo -e "${RED}b) ${LANG_OPTION_BACK}${RESET}"
                            echo "============================"
                            read -p "${LANG_PROMPT_CHOOSE} (1-$((i-1))): " lang_choice

                            if [[ "$lang_choice" == "b" ]]; then
                                TRANSLATION_MODE=""
                                break
                            elif [[ "$lang_choice" =~ ^[0-9]+$ ]] && (( lang_choice >= 1 && lang_choice <= i-1 )); then
                                SELECTED_COMMUNITY_LANG="${community_menu[$lang_choice]}"
                                return 0
                            else
                                echo -e "\n${RED}${LANG_INVALID_OPTION}${RESET} ${LANG_TRY_AGAIN}"
                                sleep 2
                            fi
                            ;;
                        *)
                            echo -e "\n${RED}${LANG_INVALID_OPTION}${RESET} ${LANG_TRY_AGAIN}"
                            sleep 2
                            ;;
                    esac
                done
                ;;
            2)
                return 0
                ;;
            *)
                echo -e "\n${RED}${LANG_INVALID_OPTION}${RESET} ${LANG_TRY_AGAIN}"
                sleep 2
                ;;
        esac
    done
}

prompt_steam_credentials() {
    clear
    read -p "${LANG_ENTER_USERNAME} " STEAM_USERNAME
    STEAM_PASSWORD="$(read_masked_password "${LANG_ENTER_PASSWORD}")"
}
