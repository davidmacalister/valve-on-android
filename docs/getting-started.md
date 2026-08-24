# Getting Started & Installation Guide

Playing classic Valve games (such as Half-Life, Half-Life 2, Counter-Strike, and Portal) natively on Android is made possible through community-developed game engine ports.

---

## Prerequisites

1. **Steam Account**: Ensure you legally own the games you wish to download on your Steam account.
2. **Termux**: Download and install the **GitHub or F-Droid version** of [Termux](https://github.com/termux/termux-app/releases).
   > ⚠️ **Warning**: Do NOT use the Google Play Store version of Termux as it is outdated and unsupported.

---

## Script Execution

Open Termux on your Android device and run the following command:

```bash
curl -LO "https://raw.githubusercontent.com/davidmacalister/Valve-on-android/main/valve-on-android.sh" && chmod +x valve-on-android.sh && ./valve-on-android.sh
```

Follow the interactive terminal prompts:
1. Select your preferred menu language.
2. Choose to download all games or select specific titles manually.
3. Select optional official or community language translation packs.
4. Enter your Steam credentials (username and password) to begin the download.

---

## Download Directory Structure

Downloaded files are automatically saved to your device's internal storage (`/storage/emulated/0/`):

- **Source Engine Games** (Half-Life 2, EP1, EP2, HL2:DM, CSS, Portal, DoD:S, HL:S):
  Saved to `/storage/emulated/0/srceng/`
- **GoldSrc Engine Games** (Half-Life, Blue Shift, Opposing Force, CS 1.6, TFC):
  Saved to `/storage/emulated/0/xash/` (or `/storage/emulated/0/xash_old/` for legacy pre-25th anniversary builds).

---

## Setting Up Game Engines on Android

To run your downloaded games, you will need the corresponding Android game engine ports:

### 1. GoldSrc Games (Xash3D FWGS)
- Install **Xash3D FWGS** and specific game client APKs (e.g., CS16Client for Counter-Strike).
- Open Xash3D FWGS, tap `+`, and select the game folder located in `/storage/emulated/0/xash/`.
- Refer to [Engine & Client Downloads](downloads.md#goldsrc) for download links.

### 2. Source Engine Games (Source Engine 4 Android)
- Install **Source Engine 4 Android** launcher and game APKs.
- Ensure the `srceng` directory is placed in the root of your internal storage (`/storage/emulated/0/srceng/`).
- Open the Source Engine launcher and select your desired game.
- Refer to [Engine & Client Downloads](downloads.md#source-engine) for download links.
