# ==========================================
# DepotDownloader Check & Installation
# ==========================================

ensure_depotdownloader_installed() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo -e "${YELLOW}[DRY RUN MODE ENABLED] DepotDownloader check bypassed.${RESET}"
        sleep 1
        return 0
    fi

    if command -v depotdownloader >/dev/null 2>&1; then
        return 0
    fi

    clear
    echo -e "${RED}[!] ${LANG_ERROR}${RESET} ${LANG_DEPOT}"
    sleep 5
    echo -e "${BOLD}${GREEN}${LANG_INSTALLING}${RESET} depotdownloader"
    sleep 3

    local install_script
    install_script="$(mktemp --tmpdir installproot.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "/tmp/installproot.sh")"
    register_temp_file "$install_script"

    if curl -sSL "https://raw.githubusercontent.com/TheKingFireS/TermuxDepotDownloader/alpine/installproot.sh" -o "$install_script"; then
        chmod +x "$install_script"
        "$install_script"
        echo -e "${BOLD}${GREEN}[*] depotdownloader ${LANG_SUCCESS}${RESET}"
        rm -f "$install_script" 2>/dev/null || true
    else
        echo -e "${RED}Failed to download TermuxDepotDownloader installer script.${RESET}"
        return 1
    fi
}
