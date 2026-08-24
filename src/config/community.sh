# ==========================================
# Community Translations Configuration
# ==========================================

declare -g -A COMMUNITY_LANG_DISPLAY
declare -g -A COMMUNITY_URLS
declare -g -A COMMUNITY_OUTFILES
declare -g -A COMMUNITY_OUTDIRS

setup_community_translations() {
    # Language display definitions using translation tokens
    COMMUNITY_LANG_DISPLAY=(
        ["pt-BR"]="${LANG_PORTUGUESE_BRAZIL} | ${LANG_BY_SRBR_MPD}"
        ["es-419"]="${LANG_SPANISH_L}"
        ["RU"]="${LANG_RUSSIAN}"
    )

    # Half-Life 2 (App 220, Depot 221)
    COMMUNITY_URLS["220:221,pt-BR"]="https://github.com/davidmacalister/Community-Translations-for-Source/releases/download/continuous/Half-Life-2-Brazilian.zip"
    COMMUNITY_OUTFILES["220:221,pt-BR"]="HL2_Brazilian.zip"
    COMMUNITY_OUTDIRS["220:221,pt-BR"]="/storage/emulated/0/srceng/hl2"

    # HL2 Episode One (App 220, Depot 389)
    COMMUNITY_URLS["220:389,pt-BR"]="https://github.com/davidmacalister/Community-Translations-for-Source/releases/download/continuous/Half-Life-2-Episode-One-Brazilian.zip"
    COMMUNITY_OUTFILES["220:389,pt-BR"]="HL2_EP1_Brazilian.zip"
    COMMUNITY_OUTDIRS["220:389,pt-BR"]="/storage/emulated/0/srceng/episodic"

    # Half-Life (App 70, Depot 1)
    COMMUNITY_URLS["70:1,pt-BR"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Half-Life-Xash-Brazilian.zip"
    COMMUNITY_URLS["70:1,RU"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Half-Life-Xash-Russian.zip"
    COMMUNITY_OUTFILES["70:1,pt-BR"]="valve_brazilian.zip"
    COMMUNITY_OUTFILES["70:1,RU"]="valve_russian.zip"
    COMMUNITY_OUTDIRS["70:1,pt-BR"]="/storage/emulated/0/xash"
    COMMUNITY_OUTDIRS["70:1,RU"]="/storage/emulated/0/xash"

    # Half-Life: Opposing Force (App 50, Depot 51)
    COMMUNITY_URLS["50:51,pt-BR"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Half-Life-Opposing-Force-Xash-Brazilian.zip"
    COMMUNITY_OUTFILES["50:51,pt-BR"]="gearbox_brazilian.zip"
    COMMUNITY_OUTDIRS["50:51,pt-BR"]="/storage/emulated/0/xash"

    # Half-Life: Blue Shift (App 130, Depot 130)
    COMMUNITY_URLS["130:130,RU"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Half-Life-Blue-Shift-Xash-Russian.zip"
    COMMUNITY_URLS["130:130,pt-BR"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Half-Life-Blue-Shift-Xash-Brazilian.zip"
    COMMUNITY_OUTFILES["130:130,pt-BR"]="bshift_brazilian.zip"
    COMMUNITY_OUTFILES["130:130,RU"]="bshift_russian.zip"
    COMMUNITY_OUTDIRS["130:130,pt-BR"]="/storage/emulated/0/xash"
    COMMUNITY_OUTDIRS["130:130,RU"]="/storage/emulated/0/xash"

    # Counter-Strike (App 10, Depot 11)
    COMMUNITY_URLS["10:11,RU"]="https://github.com/davidmacalister/Community-Translations-for-GoldSrc/releases/download/continuous/Counter-Strike-Xash-Russian.zip"
    COMMUNITY_OUTFILES["10:11,RU"]="cs_russian.zip"
    COMMUNITY_OUTDIRS["10:11,RU"]="/storage/emulated/0/xash"
}
