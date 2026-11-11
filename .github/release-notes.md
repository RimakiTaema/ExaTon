## Install

Only install builds from this repository's Releases page. `SHA256SUMS.txt` lists the SHA-256 of every file and the Android signing certificate.

### Android

1. Download `ExaTon-{{LABEL}}-android.apk` on the phone and open it.
2. If asked, allow your browser or file manager to **install unknown apps**, then tap *Install* again.
3. If Play Protect says *Unsafe app blocked* or *App scan recommended*, tap *More details* → *Install anyway*. ExaTon is not on Google Play, so Play Protect has not seen it.
4. If the device blocks apps from **unverified developers**, turn on *Settings → Developer options → Allow apps from unverified developers*, wait out the one-time 24-hour delay, then install. Or install from a computer: `adb install ExaTon-{{LABEL}}-android.apk`.

Updating: install the new APK over the old one. Your accounts and settings are kept.

### iOS / iPadOS (15+)

`ExaTon-{{LABEL}}-ios-unsigned.ipa` is **not signed** (ExaTon is not on the App Store), so it has to be signed on your own Apple ID while installing. Pick one:

- **AltStore or SideStore** (on the device): install [AltStore](https://altstore.io) or [SideStore](https://sidestore.io), open the `.ipa` with it (*Share → AltStore/SideStore*, or *My Apps → +*).
- **Sideloadly** (from a Mac or Windows PC): install [Sideloadly](https://sideloadly.io), connect the device by cable, drag the `.ipa` in, enter your Apple ID, then *Start*.

Then:

1. On iOS 16+, turn on *Settings → Privacy & Security → Developer Mode* and restart when asked.
2. Trust the profile: *Settings → General → VPN & Device Management* → your Apple ID → *Trust*.
3. With a free Apple ID the app must be re-signed every 7 days. AltStore/SideStore refresh it for you; with Sideloadly, install it again.

### macOS (11+, Apple silicon and Intel)

1. Download `ExaTon-{{LABEL}}-macos.dmg`, open it and drag **ExaTon** to **Applications**.
2. The app is not notarized, so the first launch is blocked. Open *System Settings → Privacy & Security*, scroll down and click *Open Anyway* next to ExaTon, then confirm. (macOS 14 and older: right-click ExaTon → *Open* → *Open*.)
3. If macOS says the app *is damaged*, run once in Terminal:
   ```sh
   xattr -dr com.apple.quarantine /Applications/ExaTon.app
   ```

### Windows 10/11 (x64)

Unzip `ExaTon-{{LABEL}}-windows-x64.zip` and run `ExaTon\exaton.exe`. If SmartScreen says *Windows protected your PC*, choose *More info* → *Run anyway*.

### Linux (x64)

Extract `ExaTon-{{LABEL}}-linux-x64.tar.gz` and run `ExaTon/exaton`. Needs GTK 3 and libsecret with a keyring such as GNOME Keyring or KWallet (`sudo apt install libgtk-3-0 libsecret-1-0`).
