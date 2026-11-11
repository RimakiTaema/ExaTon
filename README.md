# ExaTon

The Exaroton Server Control GUI App For Control Server Without Entering Website
(Some Feature Might Need Website For Management)

> [!WARNING]
> This Branch Was AI Assisted Please Keep In Mind that all bug caused by AI And My Bad Prompt Some AI Bug is fixable

## Major Goal

- [x] Windows Release
- [x] MacOS Release
- [x] Linux Release
- [x] Android Release (1.6, see [Android install](#android-install))
- [x] iOS Release (1.7.1, unsigned `.ipa` for sideloading, see [iOS install](#ios-install))

## Features

- [x] Login From Token
- [x] Multi Account
- [x] Console
- [x] Files
- [x] Player Control
- [x] Server Config
- [x] Personalization
- [x] Pool Credit Management (Via Webview System)
- [x] Mods and plugins from Modrinth (Add-ons tab: search, install with dependencies, update, remove)
- [x] Server alerts (crashed, online, stopped; Android also checks in the background every 15 minutes)
- [x] World backups (Files > Back up worlds / Restore a backup, as a zip)
- [x] Console player-name completion (Tab, or chips on phones) and quick commands saved from the console
- [x] Android home-screen widget (status, players, credits, Start and Stop)
- [x] Storage price (10 credits per server per month) in credit estimates, and a monthly cost calculator on each server
- [x] Update check against GitHub Releases (on launch and in Settings > About)
- [x] About page; Debug unlocks by tapping the build number 7 times

## 1.6 (Flutter)

The Flutter rewrite. One app for Windows, macOS, Linux, Android and iOS. It
talks to `api.exaroton.com` directly; `openapi.yaml` is the API reference.

### Run

```sh
flutter pub get
flutter run -d macos      # or windows, linux, android, ios
flutter test              # unit + widget tests
flutter analyze
```

No code generation step: drift is used through its SQL API.

### Layout

| Path | What |
| --- | --- |
| `lib/core/exaroton` | Pure Dart client (`client.dart`), models, websocket (`websocket.dart`). No Flutter imports. |
| `lib/core/console` | ANSI parser and the 5,000-line ring buffer. |
| `lib/core/storage` | Secure token store and the SQLite database. |
| `lib/features/*` | accounts, servers, console, players, files, config, credits, settings. |
| `lib/ui` | Theme tokens (`tokens.dart`), Material theme (`theme.dart`), shared components. |
| `lib/app/shell.dart` | Adaptive shell: bottom bar under 600 px, rail from 600, list + detail over 1024. |

### Notes

- Price constant for the Running servers estimate: `creditsPerGbHour` in
  `lib/features/credits/estimate.dart`.
- Light theme tokens are provisional (the spec has not designed them yet).
- Test fixtures in `test/fixtures` are written by hand in the shape of
  `openapi.yaml`, not captured from a live account.

## Desktop install

Download from the [Releases](../../releases) page:

| Platform | File | Notes |
| --- | --- | --- |
| Windows 10/11 (x64) | `ExaTon-<version>-windows-x64.zip` | Unzip and run `ExaTon\exaton.exe`. SmartScreen may say *Windows protected your PC*: choose *More info* → *Run anyway*. The app is not code-signed. |
| macOS 11+ (Apple silicon and Intel) | `ExaTon-<version>-macos.dmg` | Drag ExaTon to Applications. The app is not notarized, so the first launch is blocked: open *System Settings → Privacy & Security* and click *Open Anyway* (macOS 14 and older: right-click it → *Open* → *Open*). If macOS says the app is damaged, run `xattr -dr com.apple.quarantine /Applications/ExaTon.app`. |
| Linux (x64) | `ExaTon-<version>-linux-x64.tar.gz` | Extract and run `ExaTon/exaton`. Needs GTK 3 and libsecret with a keyring such as GNOME Keyring or KWallet (`sudo apt install libgtk-3-0 libsecret-1-0`). |

## Android install

Download `ExaTon-<version>-android.apk` from the [Releases](../../releases) page and
open it on the phone. ExaTon is not on Google Play, so Android treats it as a
sideloaded app.

> [!IMPORTANT]
> **App verification warnings.** You may see one of these. They are about how
> the app was installed, not a problem found in it.
>
> - **"Install unknown apps"**: allow your browser or file manager to install
>   apps when Android asks, then tap Install again.
> - **Play Protect "Unsafe app blocked" / "App scan recommended"**: tap
>   *More details* → *Install anyway*. Play Protect warns about apps it has not
>   seen from Google Play.
> - **Unverified developer (Android developer verification)**: Google is
>   rolling out a rule that apps on certified Android devices must come from a
>   registered developer. It began on 30 September 2026 in Brazil, Indonesia,
>   Singapore and Thailand and is planned worldwide in 2027. If ExaTon is not
>   registered yet and your device blocks it, turn on
>   *Settings → Developer options → Allow apps from unverified developers*,
>   wait out the one-time 24-hour delay, then install. Installing with
>   `adb install ExaTon-<version>-android.apk` from a computer is not affected.
>
> Only install builds from this repository's Releases page. Each release lists
> the SHA-256 of the APK and of its signing certificate in `SHA256SUMS.txt`;
> the certificate is the same for every release, so an update signed with a
> different key will refuse to install over the old one.

## iOS install

Download `ExaTon-<version>-ios-unsigned.ipa` from the [Releases](../../releases)
page (iOS / iPadOS 15+). ExaTon is not on the App Store and the `.ipa` is not
signed, so you sign it with your own Apple ID while installing:

- **AltStore or SideStore** (on the device): install
  [AltStore](https://altstore.io) or [SideStore](https://sidestore.io), then
  open the `.ipa` with it (*Share → AltStore/SideStore*, or *My Apps → +*).
- **Sideloadly** (from a Mac or Windows PC): install
  [Sideloadly](https://sideloadly.io), connect the device by cable, drag the
  `.ipa` in, enter your Apple ID and press *Start*.

Then turn on *Settings → Privacy & Security → Developer Mode* (iOS 16+) and
trust your Apple ID under *Settings → General → VPN & Device Management*. With
a free Apple ID the app must be re-signed every 7 days; AltStore and SideStore
do this for you.

**Build it yourself** (macOS with Xcode and CocoaPods):

```sh
flutter pub get
flutter build ios --release --no-codesign   # compile check / unsigned build
open ios/Runner.xcworkspace                  # set your Team under Signing, then Run on a device
```

The home-screen widget and background alert checks are Android only; on iOS,
alerts are checked while the app is open.

## Release signing (maintainer)

Releases are built by `.github/workflows/release.yml` when a version tag is
pushed: `v1.6.0` or `1.6.0`, optionally with a suffix such as `-beta.1`
(published as a pre-release). It builds Android, iOS (unsigned `.ipa`),
Windows, macOS and Linux and puts them in one GitHub release, with install
steps for every platform from `.github/release-notes.md` above the generated
changelog. *Actions → Release → Run workflow* builds
everything without publishing. The workflow fails, instead of publishing a
debug-signed APK, until these four repository secrets exist.

**1. Create the key once** (skip if you already have
`exatonext-release.jks`). Keep the file and passwords backed up: a lost key
means users must uninstall to update.

```sh
keytool -genkeypair -v -keystore ~/Android/keystores/exatonext-release.jks \
  -alias exatonext -keyalg RSA -keysize 4096 -validity 10000
```

**2. Local release builds.** Create `android/key.properties` (gitignored,
never commit it):

```properties
storeFile=/Users/<you>/Android/keystores/exatonext-release.jks
storePassword=<store password>
keyAlias=exatonext
keyPassword=<key password>
```

Then `flutter build apk --release`. Without this file, release builds fall
back to the debug key.

**3. GitHub secrets.** From the repo folder, with the GitHub CLI signed in
(`gh auth login`). Each `gh secret set` without `--body` asks for the value,
so passwords stay out of your shell history:

```sh
base64 -i ~/Android/keystores/exatonext-release.jks | gh secret set ANDROID_KEYSTORE_BASE64
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS        # e.g. exatonext
gh secret set ANDROID_KEY_PASSWORD
```

Or add them under *Settings → Secrets and variables → Actions*. On Linux use
`base64 -w0 <file>` instead of `base64 -i <file>`.

**4. Release.** Bump `version:` in `pubspec.yaml` and `appVersionName` /
`appVersionCode` in `lib/app/app_info.dart` (a test checks they match), commit,
then:

```sh
git tag v1.6.0 && git push origin v1.6.0     # or 1.6.0, v1.6.0-beta.1
```

The x.y.z in the tag must match `version:` in `pubspec.yaml`, or the release
stops before building.

**5. Developer verification.** To clear the "unverified developer" block,
register on the [Android Developer Console](https://developer.android.com/developer-verification)
with package name `net.rimaki.exatonext` and the release key's certificate
SHA-256:

```sh
keytool -list -v -keystore ~/Android/keystores/exatonext-release.jks -alias exatonext | grep SHA256
```

CI (`.github/workflows/ci.yml`) runs `flutter analyze`, `flutter test`, a
debug APK build and an unsigned iOS build on every push and pull request; the
APK is attached to the run as an artifact.
