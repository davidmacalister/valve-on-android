# ==========================================
# DepotDownloader Check & Installation
# ==========================================

ensure_depotdownloader_installed() {
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        return 0
    fi

    if command -v depotdownloader >/dev/null 2>&1; then
        return 0
    fi

    local install_script
    install_script="$(mktemp --tmpdir installproot.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "/tmp/installproot.sh")"
    register_temp_file "$install_script"

    download_dep() {
        curl -sSL "https://raw.githubusercontent.com/TheKingFireS/TermuxDepotDownloader/alpine/installproot.sh" -o "$install_script" && chmod +x "$install_script" && "$install_script"
    }

    run_step_with_spinner \
        "${LANG_STATUS_DOWNLOADING_DEP:-Baixando dependecia:} DepotDownloader" \
        "${LANG_STATUS_DOWNLOAD_SUCCESS:-Baixando com sucesso.}" \
        download_dep
}
