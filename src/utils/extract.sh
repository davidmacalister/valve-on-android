# ==========================================
# Archive Extraction Utilities
# ==========================================

try_install_unzip() {
    echo -e "${YELLOW}${LANG_TRY_INSTALL_7ZIP:-Installing unzip...}${RESET}"
    if command -v pkg >/dev/null 2>&1; then
        if pkg install -y unzip >/dev/null 2>&1; then
            sleep 1
            return 0
        else
            echo -e "${YELLOW}pkg install unzip failed or unavailable.${RESET}"
            return 1
        fi
    fi
    return 1
}

find_zip_extractor() {
    local cmd
    for cmd in unzip unar bsdtar; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd"
            return 0
        fi
    done

    for cmd in 7zz 7z 7za 7zr; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd"
            return 0
        fi
    done

    try_install_unzip

    for cmd in unzip unar bsdtar 7zz 7z 7za 7zr; do
        if command -v "$cmd" >/dev/null 2>&1; then
            echo "$cmd"
            return 0
        fi
    done

    return 1
}

extract_zip() {
    local archive="$1"
    local dest="$2"
    local extractor
    local log
    log="$(mktemp --tmpdir extract_log.XXXX 2>/dev/null || mktemp 2>/dev/null || echo "/tmp/extract_log.$$")"
    register_temp_file "$log"

    extractor=$(find_zip_extractor) || {
        echo -e "${YELLOW}Zip extractor not found and automatic installation failed. Cannot extract archive.${RESET}"
        rm -f "$log" 2>/dev/null || true
        return 1
    }

    local tmpdir="$dest/_extract_tmp_$$"
    mkdir -p "$tmpdir"

    local success=1
    case "$extractor" in
        unzip)
            unzip -o "$archive" -d "$tmpdir" >>"$log" 2>&1 && success=0 || success=1
            ;;
        unar)
            unar -o "$tmpdir" "$archive" >>"$log" 2>&1 && success=0 || success=1
            ;;
        bsdtar)
            bsdtar -xf "$archive" -C "$tmpdir" >>"$log" 2>&1 && success=0 || success=1
            ;;
        7zz|7z|7za|7zr)
            "$extractor" x "$archive" -o"$tmpdir" -y >>"$log" 2>&1 && success=0 || success=1
            ;;
        *)
            success=1
            ;;
    esac

    if [[ $success -ne 0 ]]; then
        for alt in unzip unar bsdtar 7zz 7z 7za 7zr; do
            [[ "$alt" == "$extractor" ]] && continue
            if command -v "$alt" >/dev/null 2>&1; then
                case "$alt" in
                    unzip) unzip -o "$archive" -d "$tmpdir" >>"$log" 2>&1 && { success=0; break; } || success=1 ;;
                    unar) unar -o "$tmpdir" "$archive" >>"$log" 2>&1 && { success=0; break; } || success=1 ;;
                    bsdtar) bsdtar -xf "$archive" -C "$tmpdir" >>"$log" 2>&1 && { success=0; break; } || success=1 ;;
                    7zz|7z|7za|7zr) "$alt" x "$archive" -o"$tmpdir" -y >>"$log" 2>&1 && { success=0; break; } || success=1 ;;
                esac
            fi
        done
    fi

    if [[ $success -ne 0 ]]; then
        echo -e "${RED}Extraction failed for ${archive}${RESET}"
        echo -e "${YELLOW}Extraction log (last 20 lines):${RESET}"
        tail -n 20 "$log" 2>/dev/null || true
        rm -rf "$tmpdir"
        rm -f "$log" 2>/dev/null || true
        return 1
    fi

    shopt -s dotglob nullglob
    local entries=( "$tmpdir"/* )
    if (( ${#entries[@]} == 1 )) && [[ -d "${entries[0]}" ]]; then
        local topdir="${entries[0]}"
        for item in "$topdir"/*; do
            mv -f "$item" "$dest"/ || echo -e "${YELLOW}Warning moving $item${RESET}"
        done
        rmdir --ignore-fail-on-non-empty "$topdir" 2>/dev/null || rm -rf "$topdir" 2>/dev/null || true
    else
        for item in "$tmpdir"/*; do
            mv -f "$item" "$dest"/ || echo -e "${YELLOW}Warning moving $item${RESET}"
        done
    fi
    shopt -u dotglob nullglob

    rm -f "$archive"
    rm -rf "$tmpdir"
    rm -f "$log" 2>/dev/null || true
    return 0
}

download_and_extract_community_pack() {
    local url="$1"
    local outdir="$2"
    local outfile="$3"
    local display_label="$4"

    mkdir -p "$outdir"
    local outpath="$outdir/$outfile"

    echo -e "${BOLD}${GREEN}${LANG_DOWNLOADING:-Downloading:}${RESET} ${display_label}"
    if ! curl -L -f -o "$outpath" "$url"; then
        echo -e "${RED}${LANG_FAILED_DOWNLOAD:-Failed to download}${RESET}"
        [[ -f "$outpath" ]] && rm -f "$outpath"
        return 1
    fi

    echo -e "${GREEN}${LANG_SUCCESS_DOWNLOAD:-Downloaded successfully}${RESET}"

    case "${outfile,,}" in
        *.zip|*.zip.*)
            if ! extract_zip "$outpath" "$outdir"; then
                echo -e "${YELLOW}Warning: extraction failed or extractor missing. Archive left in $outdir${RESET}"
                return 1
            fi
            ;;
        *)
            ;;
    esac
    return 0
}
