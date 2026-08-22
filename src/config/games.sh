# ==========================================
# Games Configuration & Catalog
# ==========================================

# Official depots by game and language
declare -A HL2_LANG_DEPOTS=(
    [french]=227 [german]=228 [russian]=225 [spanish]=226
    [korean]=229 [tchinese]=230 [schinese]=231 [italian]=232
)
declare -A HL2_EP1_LANG_DEPOTS=(
    [french]=381 [german]=382 [russian]=383 [spanish]=384
    [korean]=385 [tchinese]=386 [schinese]=387 [italian]=388
)
declare -A HL2_EP2_LANG_DEPOTS=(
    [french]=421 [german]=422 [russian]=423 [spanish]=424
)
declare -A CSS_LANG_DEPOTS=(
    [french]=243 [italian]=244 [german]=245 [spanish]=246
    [schinese]=247 [korean]=249 [tchinese]=250 [japanese]=251
    [russian]=252 [thai]=253
)
declare -A PORTAL_LANG_DEPOTS=(
    [spanish]=406 [russian]=405 [french]=407 [german]=408
)
declare -A HL_LANG_DEPOTS=(
    [french]=72 [italian]=73 [german]=74 [spanish]=75 
    [schinese]=77 [korean]=78 [tchinese]=79 [russian]=141
)
declare -A HLBS_LANG_DEPOTS=(
    [french]=131 [german]=132 
)
declare -A HLOF_LANG_DEPOTS=(
    [german]=52 [french]=53 [korean]=56 
)
declare -A CS_LANG_DEPOTS=(
    [french]=12 [italian]=13 [german]=14 [spanish]=15
    [schinese]=17 [korean]=18 [tchinese]=19 [russian]=142
)
declare -A TFC_LANG_DEPOTS=(
    [french]=22 [italian]=23 [german]=24 [spanish]=25
)

# Function to get human-readable game name from AppID and Depot ID
get_game_name() {
    local appid="$1"
    local depot="$2"

    case "$appid" in
        220)
            case "$depot" in
                221) echo "Half-Life 2" ;;
                389|380) echo "Half-Life 2: Episode 1" ;;
                420) echo "Half-Life 2: Episode 2" ;;
                *) echo "Half-Life 2 (Unknown Depot)" ;;
            esac
            ;;
        240) echo "Counter-Strike: Source" ;;
        400) echo "Portal" ;;
        70)  echo "Half-Life" ;;
        130) echo "Half-Life: Blue Shift" ;;
        50)  echo "Half-Life: Opposing Force" ;;
        10)  echo "Counter-Strike" ;;
        20)  echo "Team Fortress Classic" ;;
        320) echo "Half-Life 2: Deathmatch" ;;
        300) echo "Day of Defeat: Source" ;;
        280) echo "Half-Life: Source" ;;
        *)   echo "Unknown game (AppID $appid Depot $depot)" ;;
    esac
}

# Function to add GoldSrc 25th Anniversary games to command list
add_goldsrc_25() {
    SELECTED_GAME_ARGS+=(
        "-app 70 -depot 1 -dir xash"
        "-app 130 -depot 130 -dir xash"
        "-app 50 -depot 51 -dir xash"
        "-app 10 -depot 11 -dir xash"
        "-app 20 -depot 21 -dir xash"
    )
}

# Function to add GoldSrc Pre-25th Anniversary games to command list
add_goldsrc_pre25() {
    SELECTED_GAME_ARGS+=(
        "-branch steam_legacy -app 70 -depot 1 -dir xash_old"
        "-branch steam_legacy -app 10 -depot 11 -dir xash_old"
        "-branch steam_legacy -app 20 -depot 21 -dir xash_old"
    )
}

# Function to add Source games to command list
add_source_games() {
    SELECTED_GAME_ARGS+=(
        "-branch steam_legacy -app 220 -depot 221 -dir srceng"
        "-branch steam_legacy -app 220 -depot 389 -dir srceng"
        "-branch steam_legacy -app 220 -depot 380 -dir srceng"
        "-branch steam_legacy -app 220 -depot 420 -dir srceng"
        "-branch steam_legacy -app 320 -depot 321 -dir srceng"
        "-app 280 -depot 280 -dir srceng"
        "-branch previous_build -app 240 -depot 241 -dir srceng"
        "-branch previous_build -app 300 -depot 301 -dir srceng"
        "-app 400 -depot 401 -dir srceng"
    )
}
