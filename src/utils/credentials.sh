# ==========================================
# Secure Steam Credentials Storage Helper
# ==========================================

get_credentials_file_path() {
    local primary="${HOME}/.config/valve-on-android/credentials.conf"
    local secondary="${HOME}/.valve_on_android_credentials"
    local fallback="/tmp/valve_on_android_credentials"
    local primary_dir="$(dirname "$primary")"

    if mkdir -p "$primary_dir" 2>/dev/null && touch "$primary" 2>/dev/null; then
        echo "$primary"
    elif touch "$secondary" 2>/dev/null; then
        echo "$secondary"
    else
        echo "$fallback"
    fi
}

has_saved_credentials() {
    local cred_file
    cred_file="$(get_credentials_file_path)"
    [[ -f "$cred_file" && -s "$cred_file" ]]
}

load_saved_credentials() {
    local cred_file
    cred_file="$(get_credentials_file_path)"

    if has_saved_credentials; then
        SAVED_USERNAME=""
        SAVED_PASSWORD=""
        while IFS='=' read -r key value || [[ -n "$key" ]]; do
            case "$key" in
                USERNAME) SAVED_USERNAME="$value" ;;
                PASSWORD) SAVED_PASSWORD="$value" ;;
            esac
        done < "$cred_file"

        if [[ -n "$SAVED_USERNAME" && -n "$SAVED_PASSWORD" ]]; then
            return 0
        fi
    fi
    return 1
}

save_credentials() {
    local username="$1"
    local password="$2"
    local cred_file
    cred_file="$(get_credentials_file_path)"
    local config_dir
    config_dir="$(dirname "$cred_file")"

    mkdir -p "$config_dir" 2>/dev/null || true
    chmod 700 "$config_dir" 2>/dev/null || true

    if cat <<EOF > "$cred_file" 2>/dev/null
USERNAME=$username
PASSWORD=$password
EOF
    then
        chmod 600 "$cred_file" 2>/dev/null || true
        echo -e "${GREEN}${LANG_CREDENTIALS_SAVED:-Steam credentials saved successfully.}${RESET}"
    else
        echo -e "${YELLOW}Warning: Could not save credentials file.${RESET}"
    fi
    sleep 1
}

delete_saved_credentials() {
    local cred_file
    cred_file="$(get_credentials_file_path)"

    if [[ -f "$cred_file" ]]; then
        rm -f "$cred_file"
        echo -e "${YELLOW}${LANG_CREDENTIALS_DELETED:-Saved Steam credentials deleted.}${RESET}"
        sleep 1
    fi
}
