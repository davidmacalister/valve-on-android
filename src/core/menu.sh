# ==========================================
# Terminal UI Menus (Interactive Arrow Navigation)
# ==========================================

# Generic interactive list selector helper
# Types: "simple" (returns selected index), "radio" (single choice), "checkbox" (multi choice)
run_interactive_menu() {
    local title="$1"
    local subtitle="$2"
    local note="$3"
    local menu_type="$4" # "simple", "radio", "checkbox"
    shift 4

    local -a raw_items=()
    while [[ $# -gt 0 ]]; do
        if [[ "$1" == "---FOOTER---" ]]; then
            shift
            break
        fi
        raw_items+=("$1")
        shift
    done

    local footer_text="${1:-${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   → selecionar}}"

    local active_idx=0
    local item_count=${#raw_items[@]}

    # For radio or checkbox mode, items array contains labels.
    # We maintain an array of checked states (0 or 1).
    local -a checked=()
    for (( i=0; i<item_count; i++ )); do
        checked+=(0)
    done

    # Default first item checked for radio/checkbox if provided in initial state
    if [[ "$menu_type" == "radio" || "$menu_type" == "checkbox" ]]; then
        checked[0]=1
    fi

    # Clear screen ONCE at entry
    clear
    # Hide cursor to prevent blinking cursor flickering on screen redraw
    echo -ne "\033[?25l"

    while true; do
        # Repaint in-place from Home position with hidden cursor (0 flicker!)
        echo -ne "\033[H\033[?25l"
        echo -e "\033[K"
        echo -e "${BOLD}${title}${RESET}\033[K"
        echo -e "\033[K"

        if [[ -n "$subtitle" ]]; then
            echo -e "${subtitle}\033[K"
            echo -e "\033[K"
        fi

        if [[ -n "$note" ]]; then
            echo -e "${ITALIC}${YELLOW}${note}${RESET}\033[K"
            echo -e "\033[K"
        fi

        for (( i=0; i<item_count; i++ )); do
            local prefix="  "
            [[ $i -eq $active_idx ]] && prefix="❯ "

            local label="${raw_items[$i]}"
            local prev_label=""
            [[ $i -gt 0 ]] && prev_label="${raw_items[$((i-1))]}"

            # Spacing logic: insert blank line before Confirmar, Exit/Sair, or standalone Voltar
            if [[ "$label" == "${LANG_CONFIRM:-Confirmar}" ]]; then
                echo -e "\033[K"
            elif [[ "$label" == "Exit" || "$label" == "${LANG_EXIT:-Sair}" ]]; then
                echo -e "\033[K"
            elif [[ "$label" == "${LANG_BACK:-Voltar}" && "$prev_label" != "${LANG_CONFIRM:-Confirmar}" ]]; then
                echo -e "\033[K"
            fi

            if [[ "$menu_type" == "radio" || "$menu_type" == "checkbox" ]]; then
                if [[ "$label" == "${LANG_CONFIRM:-Confirmar}" || "$label" == "${LANG_BACK:-Voltar}" || "$label" == "Exit" || "$label" == "${LANG_EXIT:-Sair}" ]]; then
                    if [[ "$label" == "Exit" || "$label" == "${LANG_EXIT:-Sair}" ]]; then
                        if [[ $i -eq $active_idx ]]; then
                            echo -e "${prefix}${RED}${BOLD}${label}${RESET}\033[K"
                        else
                            echo -e "${prefix}${RED}${label}${RESET}\033[K"
                        fi
                    else
                        if [[ $i -eq $active_idx ]]; then
                            echo -e "${prefix}${BOLD}${label}${RESET}\033[K"
                        else
                            echo -e "${prefix}${label}${RESET}\033[K"
                        fi
                    fi
                else
                    local symbol="( )"
                    [[ ${checked[$i]} -eq 1 ]] && symbol="(●)"

                    local colored_label
                    colored_label="$(format_game_name_colored "$label")"

                    if [[ $i -eq $active_idx ]]; then
                        echo -e "${prefix}${BOLD}${symbol} ${colored_label}${RESET}\033[K"
                    else
                        echo -e "${prefix}${symbol} ${colored_label}${RESET}\033[K"
                    fi
                fi
            else
                # Simple menu
                if [[ "$label" == "Exit" || "$label" == "${LANG_EXIT:-Sair}" ]]; then
                    if [[ $i -eq $active_idx ]]; then
                        echo -e "${prefix}${RED}${BOLD}${label}${RESET}\033[K"
                    else
                        echo -e "${prefix}${RED}${label}${RESET}\033[K"
                    fi
                elif [[ "$label" == "${LANG_BACK:-Voltar}" ]]; then
                    if [[ $i -eq $active_idx ]]; then
                        echo -e "${prefix}${BOLD}${label}${RESET}\033[K"
                    else
                        echo -e "${prefix}${label}${RESET}\033[K"
                    fi
                else
                    if [[ $i -eq $active_idx ]]; then
                        echo -e "${prefix}${BOLD}${label}${RESET}\033[K"
                    else
                        echo -e "${prefix}${label}${RESET}\033[K"
                    fi
                fi
            fi
        done

        echo -e "==========================\033[K"
        echo -e "${footer_text}\033[K"
        echo -ne "\033[J" # Clear trailing lines below menu footer

        local key
        key="$(read_key)"

        case "$key" in
            UP)
                active_idx=$(( (active_idx - 1 + item_count) % item_count ))
                ;;
            DOWN)
                active_idx=$(( (active_idx + 1) % item_count ))
                ;;
            SPACE)
                if [[ "$menu_type" == "radio" ]]; then
                    # Uncheck all, check current if valid item
                    local label="${raw_items[$active_idx]}"
                    if [[ "$label" != "${LANG_CONFIRM:-Confirmar}" && "$label" != "${LANG_BACK:-Voltar}" ]]; then
                        for (( c=0; c<item_count; c++ )); do checked[$c]=0; done
                        checked[$active_idx]=1
                    fi
                elif [[ "$menu_type" == "checkbox" ]]; then
                    local label="${raw_items[$active_idx]}"
                    if [[ "$label" != "${LANG_CONFIRM:-Confirmar}" && "$label" != "${LANG_BACK:-Voltar}" ]]; then
                        if [[ ${checked[$active_idx]} -eq 1 ]]; then
                            checked[$active_idx]=0
                        else
                            checked[$active_idx]=1
                        fi
                    fi
                fi
                ;;
            ENTER)
                echo -ne "\033[?25h"
                if [[ "$menu_type" == "simple" ]]; then
                    return $active_idx
                elif [[ "$menu_type" == "radio" || "$menu_type" == "checkbox" ]]; then
                    local label="${raw_items[$active_idx]}"
                    if [[ "$label" == "${LANG_CONFIRM:-Confirmar}" ]]; then
                        # Return checked indices array as string via global VAR
                        MENU_CHECKED_INDICES=()
                        for (( c=0; c<item_count; c++ )); do
                            if [[ ${checked[$c]} -eq 1 ]]; then
                                MENU_CHECKED_INDICES+=("$c")
                            fi
                        done
                        return 0
                    elif [[ "$label" == "${LANG_BACK:-Voltar}" ]]; then
                        return 1
                    else
                        # Toggle item on enter
                        if [[ "$menu_type" == "radio" ]]; then
                            for (( c=0; c<item_count; c++ )); do checked[$c]=0; done
                            checked[$active_idx]=1
                        else
                            if [[ ${checked[$active_idx]} -eq 1 ]]; then
                                checked[$active_idx]=0
                            else
                                checked[$active_idx]=1
                            fi
                        fi
                    fi
                fi
                ;;
            BACK)
                echo -ne "\033[?25h"
                return 1
                ;;
        esac
    done
}

# Initial Language Selector
show_initial_language_menu() {
    while true; do
        run_interactive_menu \
            "${LANG_SELECT_LANG_TITLE:-Select language}" \
            "" \
            "" \
            "simple" \
            "English" \
            "Русский" \
            "Español" \
            "Português (Brasil)" \
            "Exit" \
            "---FOOTER---" \
            "↑/↓ navigate   → select"
        local choice=$?

        case "$choice" in
            0) load_language_script "english.sh" && break ;;
            1) load_language_script "russian.sh" && break ;;
            2) load_language_script "spanish.sh" && break ;;
            3) load_language_script "brazilian.sh" && break ;;
            4) echo "Exiting..."; exit 0 ;;
        esac
    done
}

# Main Menu
show_main_menu() {
    run_interactive_menu \
        "${LANG_MAIN_MENU_TITLE:-Menu principal}" \
        "" \
        "" \
        "simple" \
        "${LANG_INSTALL_GAMES:-Instalar jogos}" \
        "${LANG_MANAGE_GAMES:-Gerenciar jogos}" \
        "${LANG_ACCESS_MANUAL:-Acessar manual}" \
        "${LANG_OPTIONS:-Opções}" \
        "${LANG_EXIT:-Sair}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
    MAIN_MENU_CHOICE=$?
}

# Game Installation Selection Menu
show_installation_game_selection_menu() {
    SELECTED_GAME_ARGS=()
    local -a games=(
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
        "${LANG_CONFIRM:-Confirmar}"
        "${LANG_BACK:-Voltar}"
    )

    if ! run_interactive_menu \
        "${LANG_INSTALL_MENU_TITLE:-Menu de instalação}" \
        "${LANG_SELECT_DESIRED_GAMES:-Selecione os jogos que deseja}" \
        "" \
        "checkbox" \
        "${games[@]}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then
        return 1
    fi

    if [[ "${#MENU_CHECKED_INDICES[@]}" -eq 0 ]]; then
        return 1
    fi

    local has_goldsrc=0
    for idx in "${MENU_CHECKED_INDICES[@]}"; do
        case "$idx" in
            0|1|2|7|10) has_goldsrc=1 ;; # HL, Blue Shift, Opposing Force, CS, TFC
            3) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 221 -dir srceng") ;; # HL2
            4) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 389 -dir srceng" "-branch steam_legacy -app 220 -depot 380 -dir srceng") ;; # Ep1
            5) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 220 -depot 420 -dir srceng") ;; # Ep2
            6) SELECTED_GAME_ARGS+=("-app 280 -depot 280 -dir srceng") ;; # HL:Source
            8) SELECTED_GAME_ARGS+=("-branch previous_build -app 240 -depot 241 -dir srceng") ;; # CS:Source
            9) SELECTED_GAME_ARGS+=("-branch previous_build -app 300 -depot 301 -dir srceng") ;; # DoD:Source
            11) SELECTED_GAME_ARGS+=("-app 400 -depot 401 -dir srceng") ;; # Portal
        esac
    done

    if [[ $has_goldsrc -eq 1 ]]; then
        if ! show_goldsrc_version_menu; then
            return 1
        fi

        for idx in "${MENU_CHECKED_INDICES[@]}"; do
            if [[ "$GOLDSRC_SELECTED_VERSION" == "25th" ]]; then
                case "$idx" in
                    0) SELECTED_GAME_ARGS+=("-app 70 -depot 1 -dir xash") ;;
                    1) SELECTED_GAME_ARGS+=("-app 130 -depot 130 -dir xash") ;;
                    2) SELECTED_GAME_ARGS+=("-app 50 -depot 51 -dir xash") ;;
                    7) SELECTED_GAME_ARGS+=("-app 10 -depot 11 -dir xash") ;;
                    10) SELECTED_GAME_ARGS+=("-app 20 -depot 21 -dir xash") ;;
                esac
            else
                case "$idx" in
                    0) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 70 -depot 1 -dir xash_old") ;;
                    1) SELECTED_GAME_ARGS+=("-app 130 -depot 130 -dir xash_old") ;;
                    2) SELECTED_GAME_ARGS+=("-app 50 -depot 51 -dir xash_old") ;;
                    7) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 10 -depot 11 -dir xash_old") ;;
                    10) SELECTED_GAME_ARGS+=("-branch steam_legacy -app 20 -depot 21 -dir xash_old") ;;
                esac
            fi
        done
    fi

    return 0
}

# GoldSrc Version Selection Menu
show_goldsrc_version_menu() {
    GOLDSRC_SELECTED_VERSION="25th"
    local -a opts=(
        "${LANG_GOLDSRCVERSION_OPTION_25TH:-Versão mais recente}"
        "${LANG_GOLDSRCVERSION_OPTION_PRE25TH:-Versão anterior ao 25 Aniversário}"
        "${LANG_CONFIRM:-Confirmar}"
        "${LANG_BACK:-Voltar}"
    )

    if ! run_interactive_menu \
        "${LANG_INSTALL_MENU_TITLE:-Menu de instalação}" \
        "${LANG_SELECT_GOLDSRC_VERSION:-Selecione a versão deseja para os jogos GoldSrc}" \
        "" \
        "radio" \
        "${opts[@]}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then
        return 1
    fi

    if [[ "${MENU_CHECKED_INDICES[0]:-0}" -eq 1 ]]; then
        GOLDSRC_SELECTED_VERSION="pre25th"
    else
        GOLDSRC_SELECTED_VERSION="25th"
    fi
    return 0
}

# Steam Login Menu
show_steam_login_menu() {
    STEAM_USERNAME=""
    STEAM_PASSWORD=""

    if has_saved_credentials && load_saved_credentials; then
        STEAM_USERNAME="$SAVED_USERNAME"
        STEAM_PASSWORD="$SAVED_PASSWORD"
        return 0
    fi

    local active_idx=0
    local -a items=("${LANG_ENTER_USERNAME:-Digite seu usuário:}" "${LANG_ENTER_PASSWORD:-Digite sua senha:}" "${LANG_CONFIRM:-Confirmar}" "${LANG_BACK:-Voltar}")

    clear
    echo -ne "\033[?25l"

    while true; do
        echo -ne "\033[H\033[?25l"
        echo -e "\033[K"
        echo -e "${BOLD}${LANG_INSTALL_MENU_TITLE:-Menu de instalação}${RESET}\033[K"
        echo -e "\033[K"
        echo -e "${LANG_ENTER_STEAM_ACCOUNT:-Entre na sua conta Steam}\033[K"
        echo -e "\033[K"

        for (( i=0; i<${#items[@]}; i++ )); do
            local prefix="  "
            [[ $i -eq $active_idx ]] && prefix="❯ "
            local label="${items[$i]}"

            if [[ $i -eq 0 ]]; then
                local u_val="${STEAM_USERNAME}"
                echo -e "${prefix}${label} ${GREEN}${u_val}${RESET}\033[K"
            elif [[ $i -eq 1 ]]; then
                local p_val=""
                if [[ -n "$STEAM_PASSWORD" ]]; then
                    p_val="********"
                fi
                echo -e "${prefix}${label} ${GREEN}${p_val}${RESET}\033[K"
            elif [[ $i -eq 2 ]]; then
                echo -e "\033[K"
                if [[ $i -eq $active_idx ]]; then
                    echo -e "${prefix}${BOLD}${label}${RESET}\033[K"
                else
                    echo -e "${prefix}${label}${RESET}\033[K"
                fi
            elif [[ $i -eq 3 ]]; then
                if [[ $i -eq $active_idx ]]; then
                    echo -e "${prefix}${BOLD}${label}${RESET}\033[K"
                else
                    echo -e "${prefix}${label}${RESET}\033[K"
                fi
            fi
        done

        echo -e "==========================\033[K"
        echo -e "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}\033[K"
        echo -ne "\033[J"

        local key
        key="$(read_key)"

        case "$key" in
            UP)
                active_idx=$(( (active_idx - 1 + ${#items[@]}) % ${#items[@]} ))
                ;;
            DOWN)
                active_idx=$(( (active_idx + 1) % ${#items[@]} ))
                ;;
            ENTER)
                case "$active_idx" in
                    0)
                        echo -ne "\033[?25h"
                        echo
                        read -p "${LANG_ENTER_USERNAME:-Digite seu usuário:} " STEAM_USERNAME
                        echo -ne "\033[?25l"
                        ;;
                    1)
                        echo -ne "\033[?25h"
                        echo
                        STEAM_PASSWORD="$(read_masked_password "${LANG_ENTER_PASSWORD:-Digite sua senha:}")"
                        echo -ne "\033[?25l"
                        ;;
                    2)
                        echo -ne "\033[?25h"
                        if [[ -n "$STEAM_USERNAME" && -n "$STEAM_PASSWORD" ]]; then
                            save_credentials "$STEAM_USERNAME" "$STEAM_PASSWORD"
                            return 0
                        fi
                        ;;
                    3)
                        echo -ne "\033[?25h"
                        return 1
                        ;;
                esac
                ;;
            BACK)
                echo -ne "\033[?25h"
                return 1
                ;;
        esac
    done
}

# Options Menu
show_options_menu() {
    while true; do
        run_interactive_menu \
            "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
            "" \
            "" \
            "simple" \
            "${LANG_STEAM_ACCOUNTS:-Contas Steam}" \
            "${LANG_INTERFACE_LANG:-Idiomas}" \
            "${LANG_DISPLAY_SETTINGS:-Exibir}" \
            "${LANG_BACK:-Voltar}" \
            "---FOOTER---" \
            "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
        local opt_choice=$?

        case "$opt_choice" in
            0) show_steam_accounts_menu ;;
            1) show_languages_menu ;;
            2) show_display_options_menu ;;
            3) return 0 ;;
        esac
    done
}

# Steam Accounts Menu
show_steam_accounts_menu() {
    while true; do
        load_saved_credentials 2>/dev/null || true

        local subtitle="${LANG_SAVED_ACCOUNTS_HEADER:-Contas salvas:}\n"
        if [[ "${#SAVED_USERNAMES[@]}" -gt 0 ]]; then
            for (( i=0; i<${#SAVED_USERNAMES[@]}; i++ )); do
                if [[ $i -eq ${SAVED_ACTIVE_INDEX:-0} ]]; then
                    subtitle+="${GREEN}${SAVED_USERNAMES[$i]} (${LANG_IN_USE:-em uso})${RESET}\n"
                else
                    subtitle+="${SAVED_USERNAMES[$i]}\n"
                fi
            done
        else
            subtitle+="${YELLOW}(Nenhuma conta salva)${RESET}\n"
        fi

        run_interactive_menu \
            "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
            "$subtitle" \
            "" \
            "simple" \
            "${LANG_CHANGE_USED_ACCOUNT:-Alterar conta usada}" \
            "${LANG_ADD_NEW_ACCOUNT:-Adicionar uma nova conta}" \
            "${LANG_REMOVE_SAVED_ACCOUNTS:-Remover contas salvas}" \
            "${LANG_BACK:-Voltar}" \
            "---FOOTER---" \
            "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
        local choice=$?

        case "$choice" in
            0)
                if [[ "${#SAVED_USERNAMES[@]}" -gt 0 ]]; then
                    local -a account_opts=()
                    for (( i=0; i<${#SAVED_USERNAMES[@]}; i++ )); do
                        account_opts+=("${SAVED_USERNAMES[$i]}")
                    done
                    account_opts+=("${LANG_CONFIRM:-Confirmar}" "${LANG_BACK:-Voltar}")

                    if run_interactive_menu "${LANG_OPTIONS_MENU_TITLE:-Opções}" "${LANG_CHANGE_USED_ACCOUNT:-Alterar conta usada}" "" "radio" "${account_opts[@]}" "---FOOTER---" "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then
                        local selected_acc_idx="${MENU_CHECKED_INDICES[0]:-0}"
                        set_active_account "$selected_acc_idx"
                    fi
                fi
                ;;
            1)
                clear
                echo
                echo -e "${BOLD}${LANG_OPTIONS_MENU_TITLE:-Opções}${RESET}"
                echo
                local new_user new_pass
                read -p "${LANG_ENTER_USERNAME:-Digite seu usuário:} " new_user
                new_pass="$(read_masked_password "${LANG_ENTER_PASSWORD:-Digite sua senha:}")"
                if [[ -n "$new_user" && -n "$new_pass" ]]; then
                    save_credentials "$new_user" "$new_pass"
                fi
                ;;
            2)
                delete_saved_credentials
                ;;
            3)
                return 0
                ;;
        esac
    done
}

# Languages Submenu
show_languages_menu() {
    while true; do
        run_interactive_menu \
            "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
            "" \
            "" \
            "simple" \
            "${LANG_INTERFACE_LANG:-Idioma da interface}" \
            "${LANG_GAMES_LANG:-Idioma dos jogos}" \
            "${LANG_BACK:-Voltar}" \
            "---FOOTER---" \
            "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
        local lang_choice=$?

        case "$lang_choice" in
            0) show_interface_language_menu ;;
            1) show_games_language_menu ;;
            2) return 0 ;;
        esac
    done
}

# Interface Language Menu
show_interface_language_menu() {
    local -a lang_opts=(
        "English"
        "Русский"
        "Español"
        "Português (Brasil)"
        "${LANG_CONFIRM:-Confirmar}"
        "${LANG_BACK:-Voltar}"
    )

    if run_interactive_menu \
        "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
        "${LANG_SELECT_INTERFACE_LANG:-Selecione o idioma deseja para a interface}" \
        "" \
        "radio" \
        "${lang_opts[@]}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then
        case "${MENU_CHECKED_INDICES[0]:-0}" in
            0) load_language_script "english.sh" ;;
            1) load_language_script "russian.sh" ;;
            2) load_language_script "spanish.sh" ;;
            3) load_language_script "brazilian.sh" ;;
        esac
    fi
}

# Games Language Menu
show_games_language_menu() {
    local -a game_lang_opts=(
        "English"
        "Русский"
        "Español"
        "Français"
        "Deutsch"
        "Italiano"
        "Português (Brasil)"
        "${LANG_CONFIRM:-Confirmar}"
        "${LANG_BACK:-Voltar}"
    )

    if run_interactive_menu \
        "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
        "${LANG_SELECT_GAMES_LANG:-Selecione o idioma deseja para os jogos}" \
        "${LANG_GAMES_LANG_NOTE:-Nota: alguns idiomas não estão disponíveis em todos os jogos ou tem traduções de maneira oficial, então nesses casos são usadas traduções da comunidade quando disponíveis.}" \
        "radio" \
        "${game_lang_opts[@]}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then
        case "${MENU_CHECKED_INDICES[0]:-0}" in
            0) SELECTED_OFFICIAL_LANG="english" ;;
            1) SELECTED_OFFICIAL_LANG="russian" ;;
            2) SELECTED_OFFICIAL_LANG="spanish" ;;
            3) SELECTED_OFFICIAL_LANG="french" ;;
            4) SELECTED_OFFICIAL_LANG="german" ;;
            5) SELECTED_OFFICIAL_LANG="italian" ;;
            6) SELECTED_OFFICIAL_LANG="portuguese" ;;
        esac
        TRANSLATION_MODE="official"
    fi
}

# Display Options Menu
show_display_options_menu() {
    local current_dry="${DRY_RUN:-0}"
    local dry_label="Desativado"
    [[ "$current_dry" == "1" ]] && dry_label="Ativado"

    run_interactive_menu \
        "${LANG_OPTIONS_MENU_TITLE:-Opções}" \
        "Modo de Simulação (Dry-Run): $dry_label" \
        "" \
        "simple" \
        "Alternar Modo Simulação (Dry-Run)" \
        "${LANG_BACK:-Voltar}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
    local choice=$?

    if [[ $choice -eq 0 ]]; then
        if [[ "${DRY_RUN:-0}" == "1" ]]; then
            export DRY_RUN="0"
        else
            export DRY_RUN="1"
        fi
    fi
}

# Game Management Menu
show_game_management_menu() {
    while true; do
        run_interactive_menu \
            "${LANG_MANAGEMENT_TITLE:-Gerenciamento de jogos}" \
            "" \
            "" \
            "simple" \
            "${LANG_UNINSTALL_GAME:-Desinstalar jogo}" \
            "${LANG_VERIFY_INTEGRITY:-Atualizar/Verificar integridade}" \
            "${LANG_BACK:-Voltar}" \
            "---FOOTER---" \
            "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
        local choice=$?

        case "$choice" in
            0) show_uninstall_game_selection_menu ;;
            1)
                show_verify_integrity_menu
                if [[ "${#VERIFY_INDICES[@]}" -gt 0 ]]; then
                    show_steam_login_menu
                    execute_verification_downloads "$STEAM_USERNAME" "$STEAM_PASSWORD" "${VERIFY_INDICES[@]}"
                fi
                ;;
            2) return 0 ;;
        esac
    done
}

# Uninstall Selection Menu
show_uninstall_game_selection_menu() {
    load_installed_games_list
    local count="${#INSTALLED_GAMES_ARGS[@]}"

    if [[ "$count" -eq 0 ]]; then
        clear
        echo
        echo -e "${YELLOW}${LANG_NO_INSTALLED_GAMES:-Nenhum jogo instalado foi encontrado.}${RESET}"
        sleep 2
        return 1
    fi

    local -a uninstall_opts=()
    for name in "${INSTALLED_GAMES_NAMES[@]}"; do
        uninstall_opts+=("$name")
    done
    uninstall_opts+=("${LANG_CONFIRM:-Confirmar}" "${LANG_BACK:-Voltar}")

    if run_interactive_menu \
        "${LANG_MANAGEMENT_TITLE:-Gerenciamento de jogos}" \
        "${LANG_SELECT_UNINSTALL_GAMES:-Selecione os jogos que deseja desinstalar}" \
        "" \
        "checkbox" \
        "${uninstall_opts[@]}" \
        "---FOOTER---" \
        "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"; then

        for idx in "${MENU_CHECKED_INDICES[@]}"; do
            local game_args="${INSTALLED_GAMES_ARGS[$idx]:-}"
            local game_dir="$(get_dir_from_args "$game_args")"
            if [[ -n "$game_dir" ]]; then
                echo -e "${YELLOW}Removendo diretório: ${SET_DIR}${game_dir}${RESET}"
                rm -rf "${SET_DIR}${game_dir}" 2>/dev/null || true
            fi
        done
        echo -e "${GREEN}Jogos selecionados foram removidos.${RESET}"
        sleep 2
    fi
}

# Verify Integrity Menu
show_verify_integrity_menu() {
    load_installed_games_list
    local count="${#INSTALLED_GAMES_ARGS[@]}"

    if [[ "$count" -eq 0 ]]; then
        clear
        echo
        echo -e "${YELLOW}${LANG_NO_INSTALLED_GAMES:-Nenhum jogo instalado foi encontrado.}${RESET}"
        sleep 2
        return 1
    fi

    VERIFY_INDICES=()
    for (( i=0; i<count; i++ )); do
        VERIFY_INDICES+=("$i")
    done
    return 0
}

# Documentation & Manual Reader Menu
show_manual_menu() {
    while true; do
        run_interactive_menu \
            "${LANG_MANUAL_TITLE:-Manual e Documentação}" \
            "Selecione um tópico para leitura:" \
            "" \
            "simple" \
            "Guia de Início Rápido (getting-started.md)" \
            "Jogos Suportados (supported-games.md)" \
            "Mods Suportados (supported-mods.md)" \
            "${LANG_BACK:-Voltar}" \
            "---FOOTER---" \
            "${LANG_NAVIGATE_FOOTER:-↑/↓ navegar   Enter selecionar}"
        local choice=$?

        local doc_file=""
        case "$choice" in
            0) doc_file="${SCRIPT_DIR}/docs/getting-started.md" ;;
            1) doc_file="${SCRIPT_DIR}/docs/supported-games.md" ;;
            2) doc_file="${SCRIPT_DIR}/docs/supported-mods.md" ;;
            3) return 0 ;;
        esac

        if [[ -f "$doc_file" ]]; then
            clear
            echo -e "${BOLD}========================================${RESET}"
            echo -e "${BOLD}${doc_file##*/}${RESET}"
            echo -e "${BOLD}========================================${RESET}\n"
            cat "$doc_file"
            echo
            read -p "${LANG_PRESS_ENTER:-Pressione ENTER para voltar...}" _
        fi
    done
}
