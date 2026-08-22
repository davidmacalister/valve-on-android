# ==========================================
# Internationalization (i18n) Helper
# ==========================================

declare -A LANG_DISPLAY_NAMES

load_language_script() {
    local lang_filename="$1"
    local local_file="${SCRIPT_DIR}/locales/${lang_filename}"
    local remote_url="https://raw.githubusercontent.com/kennedcandido/Valve-on-android/main/locales/${lang_filename}"
    local temp_file

    if [[ -s "$local_file" ]]; then
        source "$local_file"
        setup_language_display_names
        return 0
    fi

    temp_file="$(mktemp --tmpdir lang_temp.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "${SCRIPT_DIR}/lang_temp.sh")"
    register_temp_file "$temp_file"

    if curl -sSL "$remote_url" -o "$temp_file" && [[ -s "$temp_file" ]]; then
        source "$temp_file"
        setup_language_display_names
        rm -f "$temp_file" 2>/dev/null || true
        return 0
    fi

    echo -e "${RED}Failed to load language file: ${lang_filename}${RESET}"
    return 1
}

setup_language_display_names() {
    LANG_DISPLAY_NAMES=(
        [english]="${LANG_ENGLISH:-English}"
        [thai]="${LANG_THAI:-Thai}"
        [french]="${LANG_FRENCH:-French}"
        [german]="${LANG_GERMAN:-German}"
        [russian]="${LANG_RUSSIAN:-Russian}"
        [spanish]="${LANG_SPANISH_E:-Spanish}"
        [korean]="${LANG_KOREAN:-Korean}"
        [tchinese]="${LANG_TCHINESE:-Traditional Chinese}"
        [schinese]="${LANG_SCHINESE:-Simplified Chinese}"
        [italian]="${LANG_ITALIAN:-Italian}"
        [japanese]="${LANG_JAPANESE:-Japanese}"
    )
}
