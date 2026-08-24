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

    SAVED_USERNAMES=()
    SAVED_PASSWORDS=()
    SAVED_ACTIVE_INDEX=-1
    SAVED_USERNAME=""
    SAVED_PASSWORD=""

    if has_saved_credentials; then
        local idx=0
        while IFS='=' read -r key value || [[ -n "$key" ]]; do
            case "$key" in
                ACCOUNT)
                    IFS=':' read -r uname pass active <<< "$value"
                    if [[ -n "$uname" && -n "$pass" ]]; then
                        SAVED_USERNAMES+=("$uname")
                        SAVED_PASSWORDS+=("$pass")
                        if [[ "$active" == "1" || "$SAVED_ACTIVE_INDEX" -eq -1 ]]; then
                            SAVED_ACTIVE_INDEX=$idx
                        fi
                        ((idx++))
                    fi
                    ;;
                USERNAME)
                    SAVED_USERNAME="$value"
                    ;;
                PASSWORD)
                    SAVED_PASSWORD="$value"
                    ;;
            esac
        done < "$cred_file"

        # Backward compatibility for legacy single-account file format
        if [[ "${#SAVED_USERNAMES[@]}" -eq 0 && -n "$SAVED_USERNAME" && -n "$SAVED_PASSWORD" ]]; then
            SAVED_USERNAMES+=("$SAVED_USERNAME")
            SAVED_PASSWORDS+=("$SAVED_PASSWORD")
            SAVED_ACTIVE_INDEX=0
        fi

        if [[ "${#SAVED_USERNAMES[@]}" -gt 0 ]]; then
            if [[ "$SAVED_ACTIVE_INDEX" -lt 0 ]]; then
                SAVED_ACTIVE_INDEX=0
            fi
            SAVED_USERNAME="${SAVED_USERNAMES[$SAVED_ACTIVE_INDEX]}"
            SAVED_PASSWORD="${SAVED_PASSWORDS[$SAVED_ACTIVE_INDEX]}"
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

    load_saved_credentials 2>/dev/null || true

    mkdir -p "$config_dir" 2>/dev/null || true
    chmod 700 "$config_dir" 2>/dev/null || true

    local -a new_users=()
    local -a new_passes=()
    local target_active_idx=-1

    for (( i=0; i<${#SAVED_USERNAMES[@]}; i++ )); do
        if [[ "${SAVED_USERNAMES[$i]}" == "$username" ]]; then
            new_users+=("$username")
            new_passes+=("$password")
            target_active_idx=$i
        else
            new_users+=("${SAVED_USERNAMES[$i]}")
            new_passes+=("${SAVED_PASSWORDS[$i]}")
        fi
    done

    if [[ $target_active_idx -eq -1 ]]; then
        new_users+=("$username")
        new_passes+=("$password")
        target_active_idx=$(( ${#new_users[@]} - 1 ))
    fi

    {
        for (( i=0; i<${#new_users[@]}; i++ )); do
            local is_act=0
            [[ $i -eq $target_active_idx ]] && is_act=1
            echo "ACCOUNT=${new_users[$i]}:${new_passes[$i]}:${is_act}"
        done
        echo "USERNAME=$username"
        echo "PASSWORD=$password"
    } > "$cred_file" 2>/dev/null

    chmod 600 "$cred_file" 2>/dev/null || true

    # Reload credentials to update active index and user variables in memory
    load_saved_credentials 2>/dev/null || true
}

set_active_account() {
    local target_idx="$1"
    load_saved_credentials || return 1

    if [[ "$target_idx" -ge 0 && "$target_idx" -lt "${#SAVED_USERNAMES[@]}" ]]; then
        save_credentials "${SAVED_USERNAMES[$target_idx]}" "${SAVED_PASSWORDS[$target_idx]}"
        return 0
    fi
    return 1
}

delete_saved_credentials() {
    local cred_file
    cred_file="$(get_credentials_file_path)"

    if [[ -f "$cred_file" ]]; then
        rm -f "$cred_file"
        SAVED_USERNAMES=()
        SAVED_PASSWORDS=()
        SAVED_USERNAME=""
        SAVED_PASSWORD=""
        SAVED_ACTIVE_INDEX=-1
    fi
}

