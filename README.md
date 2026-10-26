# SkillSwap

SkillSwap is a student skill-sharing app: **Learn Something. Share Something.**
Students can list skills, discover other students' active listings, and manage
learning requests.

## Features

- Material 3 interface with Discover, My Skills, Requests, and Profile tabs.
- Skill listings with category filters and search.
- Local demo registration and sign-in, profile editing, and request workflow.
- Existing splash screen and app theme.

## Offline demo limitations

This app does not use a backend. Accounts, passwords, profiles, skills, and
requests are held only in memory and disappear when the process closes. The
local sign-in flow is only for trying the UI; it is not real authentication,
does not protect data, and must not be used for sensitive information.
Password reset is unavailable in offline demo mode. Data is not shared between
devices or app installations.

## Prerequisites and setup

- Flutter SDK and Dart SDK compatible with `pubspec.yaml`.
- For Android, Android SDK and a USB data cable.

From the project root:

```sh
flutter pub get
flutter run
```

## Real Android device

1. On the phone, open **Settings → About phone** and tap **Build number**
   seven times to enable Developer options (menu names vary by device).
2. In **Developer options**, enable **USB debugging**.
3. Connect the phone using a USB data cable, unlock it, and accept the USB
   debugging authorization prompt.
4. Run `flutter devices` and confirm the phone is listed.
5. Run `flutter run -d DEVICE_ID`, replacing `DEVICE_ID` with the actual ID
   printed by `flutter devices`.

## Tests and checks

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

## Manual checks

- Launch and navigate through all four tabs.
- Create two temporary demo accounts in one app run.
- Edit profile details and share/edit/delete skills.
- Search and filter listings.
- Send, accept, decline, cancel, and complete requests using the two accounts.
- Check empty states, keyboard behavior, and different screen sizes.
- Restart the app and confirm the demo data has been cleared.

These are testing steps, not claims that every flow has been manually verified.

## Git review and push

Review changes before committing:

```sh
git status
git diff
git diff --check
```

After reviewing and committing locally, push the branch yourself:

```sh
git push -u origin HEAD
```
