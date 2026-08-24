# ==========================================
# Internationalization (i18n) Helper
# ==========================================

declare -A LANG_DISPLAY_NAMES

load_language_script() {
    local lang_filename="$1"
    local local_file="${SCRIPT_DIR}/locales/${lang_filename}"
    local remote_url="https://raw.githubusercontent.com/kennedcandido/Valve-on-android/main/locales/${lang_filename}"

    if [[ -d "${SCRIPT_DIR}/.git" && -s "$local_file" ]]; then
        source "$local_file"
        setup_language_display_names
        return 0
    fi

    mkdir -p "${SCRIPT_DIR}/locales"
    if curl -sSL "$remote_url" -o "$local_file" && [[ -s "$local_file" ]]; then
        source "$local_file"
        setup_language_display_names
        return 0
    elif [[ -s "$local_file" ]]; then
        source "$local_file"
        setup_language_display_names
        return 0
    fi

    echo -e "${RED:-}Failed to load language file: ${lang_filename}${RESET:-}"
    return 1
}

setup_language_display_names() {
    declare -g -A LANG_DISPLAY_NAMES
    LANG_DISPLAY_NAMES["english"]="${LANG_ENGLISH:-English}"
    LANG_DISPLAY_NAMES["thai"]="${LANG_THAI:-Thai}"
    LANG_DISPLAY_NAMES["french"]="${LANG_FRENCH:-French}"
    LANG_DISPLAY_NAMES["german"]="${LANG_GERMAN:-German}"
    LANG_DISPLAY_NAMES["russian"]="${LANG_RUSSIAN:-Russian}"
    LANG_DISPLAY_NAMES["spanish"]="${LANG_SPANISH_E:-Spanish}"
    LANG_DISPLAY_NAMES["korean"]="${LANG_KOREAN:-Korean}"
    LANG_DISPLAY_NAMES["tchinese"]="${LANG_TCHINESE:-Traditional Chinese}"
    LANG_DISPLAY_NAMES["schinese"]="${LANG_SCHINESE:-Simplified Chinese}"
    LANG_DISPLAY_NAMES["italian"]="${LANG_ITALIAN:-Italian}"
    LANG_DISPLAY_NAMES["japanese"]="${LANG_JAPANESE:-Japanese}"
}
