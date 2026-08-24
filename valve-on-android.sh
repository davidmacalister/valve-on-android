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
# Load Modular Subsystems (local or remote)
# ==========================================
load_module() {
    local module_rel_path="$1"
    local local_path="${SCRIPT_DIR}/${module_rel_path}"
    local remote_url="https://raw.githubusercontent.com/kennedcandido/Valve-on-android/main/${module_rel_path}"

    if [[ -d "${SCRIPT_DIR}/.git" && -s "$local_path" ]]; then
        source "$local_path"
        return 0
    fi

    mkdir -p "$(dirname "$local_path")"
    if curl -sSL "$remote_url" -o "$local_path" && [[ -s "$local_path" ]]; then
        source "$local_path"
        return 0
    elif [[ -s "$local_path" ]]; then
        source "$local_path"
        return 0
    else
        echo "Error: Failed to download required module ${module_rel_path}" >&2
        exit 1
    fi
}

load_module "src/utils/terminal.sh"
load_module "src/utils/i18n.sh"
load_module "src/utils/extract.sh"
load_module "src/utils/credentials.sh"
load_module "src/utils/installation_log.sh"
load_module "src/config/games.sh"
load_module "src/config/community.sh"
load_module "src/core/depot.sh"
load_module "src/core/download.sh"
load_module "src/core/menu.sh"

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
    VERIFY_INDICES=()
    MAIN_MENU_CHOICE=""
    STEAM_USERNAME=""
    STEAM_PASSWORD=""

    show_main_menu

    case "$MAIN_MENU_CHOICE" in
        0)
            if ! show_installation_game_selection_menu; then
                continue
            fi
            if [[ "${#SELECTED_GAME_ARGS[@]}" -eq 0 ]]; then
                continue
            fi
            show_steam_login_menu
            execute_downloads "$STEAM_USERNAME" "$STEAM_PASSWORD"
            ;;
        1)
            show_game_management_menu
            ;;
        2)
            show_manual_menu
            ;;
        3)
            show_options_menu
            ;;
        4)
            clear
            echo -e "${RED}${LANG_EXITING:-Saindo...}${RESET}"
            exit 0
            ;;
    esac
done

