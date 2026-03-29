# Run Ma3ak in Android Studio with Emulator

## 1. Open the correct project folder

**Important:** In Android Studio, open the **`appm3ak`** folder (this folder that contains `pubspec.yaml` and the `android` folder), **not** the parent `appmaak` folder.

- Correct: `...\appmaak\appm3ak`
- Wrong: `...\appmaak`

## 2. Android SDK licenses (one-time)

If you see license or SDK errors, run in a terminal (from this folder):

```bash
flutter doctor --android-licenses
```

Accept all when prompted.

## 3. Start an Android emulator

- In Android Studio: **Tools → Device Manager** → create or start an AVD (Android Virtual Device).
- Or from terminal: `flutter emulators` then `flutter emulators --launch <emulator_id>`.

## 4. Run the app

- In Android Studio: select your emulator in the device dropdown, then click **Run** (green play button), or press **Shift+F10**.
- Or from terminal (with emulator running):  
  `flutter run`

## 5. If you see "Building with plugins requires symlink support"

Enable **Developer Mode** in Windows:

1. Press **Win + I** → **Privacy & security** → **For developers**.
2. Turn **Developer Mode** **On**.

Then run again.

## 6. Optional: install cmdline-tools (if suggested by Flutter doctor)

If Flutter says cmdline-tools are missing, in Android Studio: **Settings → Languages & Frameworks → Android SDK → SDK Tools** → check **Android SDK Command-line Tools** → Apply.
