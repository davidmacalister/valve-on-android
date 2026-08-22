#!/usr/bin/env bash

# ==========================================
# Safety & Environment Settings
# ==========================================
set -o pipefail
shopt -s failglob
set -u

# Resolve current script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SET_DIR="/storage/emulated/0/"

# Dry-run mode flag (set via DRY_RUN=1 env var or --dry-run / -d argument)
export DRY_RUN="${DRY_RUN:-0}"

for arg in "$@"; do
    case "$arg" in
        --dry-run|-d)
            export DRY_RUN="1"
            ;;
    esac
done

# ==========================================
# Load Modular Subsystems
# ==========================================
source "${SCRIPT_DIR}/src/utils/terminal.sh"
source "${SCRIPT_DIR}/src/utils/i18n.sh"
source "${SCRIPT_DIR}/src/utils/extract.sh"
source "${SCRIPT_DIR}/src/config/games.sh"
source "${SCRIPT_DIR}/src/config/community.sh"
source "${SCRIPT_DIR}/src/core/depot.sh"
source "${SCRIPT_DIR}/src/core/download.sh"
source "${SCRIPT_DIR}/src/core/menu.sh"

# ==========================================
# Initialize Application
# ==========================================
show_initial_language_menu
ensure_depotdownloader_installed

# ==========================================
# Main Application Loop
# ==========================================
while true; do
    SELECTED_GAME_ARGS=()
    MAIN_MENU_CHOICE=""
    STEAM_USERNAME=""
    STEAM_PASSWORD=""

    show_main_menu

    case "$MAIN_MENU_CHOICE" in
        1)
            if ! show_all_games_menu; then
                continue
            fi
            ;;
        2)
            if ! show_manual_game_selection_menu; then
                continue
            fi
            ;;
        3)
            echo -e "${RED}${LANG_EXITING}${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] ${LANG_INVALID_OPTION}${RESET}"
            sleep 2
            continue
            ;;
    esac

    if [[ "${#SELECTED_GAME_ARGS[@]}" -eq 0 ]]; then
        echo -e "${RED}[!] ${LANG_NO_COMMANDS}${RESET}"
        sleep 2
        continue
    fi

    if ! show_language_pack_menu; then
        continue
    fi

    prompt_steam_credentials
    execute_downloads "$STEAM_USERNAME" "$STEAM_PASSWORD"

    read -p "${LANG_PRESS_ENTER}" _
done
