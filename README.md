# My Boji — Website + Android app

Arabic-first RTL automotive and motorcycle spare-parts storefront. The project remains a React + TypeScript + Vite website and uses Capacitor to package the same application for Android.

**Single-owner model:** there are no customer seller accounts or multi-vendor registration. Customers who want to offer a part must contact the store owner through WhatsApp: [+963 937 306 331](https://wa.me/963937306331).

## Existing functionality preserved

- Supabase-backed public product catalog (published products only).
- Product search and car/motorcycle category filtering.
- Product details and WhatsApp inquiries.
- Supabase email/password owner sign-in.
- Admin access allowlist using `admin_profiles`.
- Owner product create/edit/delete, stock, publication and featured controls.
- Category management and product image upload.
- PostgreSQL schema and Row Level Security policies in `supabase/schema.sql`.

## Requirements

- Node.js 20.19+ or 22.12+
- Android Studio (current stable) with Android SDK and platform tools
- JDK 21 (recommended for current Android Gradle Plugin toolchains)
- A Supabase project

## 1. Supabase setup

1. Run all of `supabase/schema.sql` in the Supabase SQL Editor.
2. Create the owner account under **Authentication → Users**. Disable public sign-ups.
3. Copy the owner's auth user UUID and add it to `public.admin_profiles`:
   ```sql
   insert into public.admin_profiles (user_id)
   values ('OWNER-AUTH-USER-UUID');
   ```
4. Copy the Supabase Project URL and public anon/publishable key.

Authentication alone does not grant administrator access. The authenticated UUID must be allowlisted in `admin_profiles`; database RLS remains the security boundary.

## 2. Configure environment variables

Copy `.env.example` to `.env` in the repository root and fill in your own values:

```env
VITE_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_PUBLIC_ANON_OR_PUBLISHABLE_KEY
```

The app also accepts `VITE_SUPABASE_PUBLISHABLE_KEY` if that is the variable already used in your environment.

Never put a Supabase `service_role` or secret key in this frontend project. Do not commit `.env`. The public anon/publishable key is expected in a browser app; RLS must protect all data.

## 3. Run the website

```bash
npm install
npm run dev
```

Production website build:

```bash
npm run build
npm run preview
```

Deploy `dist/` to your preferred static host and configure the same two public Supabase environment variables in that host's build settings. This does not generate an APK.

## 4. Android project setup (first time)

Capacitor configuration is included in `capacitor.config.ts`:

- App name: `My Boji`
- Android application ID: `com.myboji.store`
- Web output directory: `dist`

Install dependencies and create the native Android project. Run `npm install` first; it will resolve the added Capacitor packages and refresh the inherited npm lockfile with the new dependency tree. Commit the refreshed `package-lock.json` after installation:

```bash
npm install
npx cap add android
```

Generate Android launcher and splash resources from the supplied official artwork:

```bash
npx capacitor-assets generate --android
```

The artwork sources are in `resources/`:
- `resources/icon.png` — square launcher artwork using the B/spark-plug symbol.
- `resources/splash.png` — official full logo on the brand's dark background.

The full logo is also included in `public/assets/my-boji-logo.jpg` and is used in the website UI. The favicon is `public/assets/my-boji-icon.png`.

Then build the web app and synchronize it into Android:

```bash
npm run android:sync
```

Open the native project:

```bash
npx cap open android
```

In Android Studio, allow Gradle sync to finish, install the Android SDK versions requested by the project if prompted, then run on an emulator or connected Android phone.

### Android package scripts

```bash
npm run android:sync     # Build Vite output and sync it to native Android
npm run android:open     # Open Android Studio project
npm run android:debug    # Build and assemble a debug APK
npm run android:release  # Assemble an unsigned release APK (unless signing is configured)
```

The first `npx cap add android` step creates the `android/` directory. Commit that generated directory to GitHub so the native project is part of the repository. Do not run `cap add android` again after it already exists.

## 5. Create a signed release APK

For a distributable APK, create a private Android signing keystore. Keep the keystore and passwords outside GitHub and back them up securely.

Recommended GUI workflow:

1. Run `npm run android:sync`.
2. Open the project with `npm run android:open`.
3. In Android Studio choose **Build → Generate Signed Bundle / APK**.
4. Select **APK** (not AAB) for direct download and installation.
5. Create or select your release keystore, key alias and passwords.
6. Select the `release` build variant and complete the wizard.
7. Find the resulting APK under `android/app/build/outputs/apk/release/`.

You can also configure Gradle release signing using environment variables or a local, untracked properties file. Never put signing passwords or keystore files in source control. An unsigned `assembleRelease` output is not suitable for normal customer distribution.

For installation, transfer the signed APK to the Android phone, open it, and allow installation from that source if Android asks. Distribute only the APK signed with the same private key for future in-place upgrades; losing the key means users generally need to uninstall the old app before installing a differently signed build.

## 6. Future app updates

After changing React code or website assets:

```bash
npm install
npm run android:sync
```

Then build a signed release APK in Android Studio using the same keystore and key alias. Increase `versionCode` and `versionName` in the Android app Gradle configuration before each customer update. Publish the APK as an asset on a GitHub Release; GitHub Pages is website hosting and does not build Android APKs.

If native Capacitor plugins or Android settings change, run:

```bash
npx cap sync android
```

## 7. GitHub publishing

```bash
git init
git add .
git commit -m "Prepare My Boji website and Android app"
git branch -M main
git remote add origin https://github.com/YOUR-ACCOUNT/YOUR-REPOSITORY.git
git push -u origin main
```

Before pushing, verify that `.env`, signing keys, passwords, and `local.properties` are not staged:

```bash
git status --short
```

For an APK release: open the repository on GitHub → **Releases** → **Draft a new release**, add a version tag (for example `v1.0.0`), attach the signed APK, and publish. Do not upload a keystore or secret values.

## Security and behavior notes

- There is no seller registration flow. The public-facing "sell a part" contact routes to the owner WhatsApp number.
- The frontend only uses Supabase anon/publishable credentials. Never use a service-role key in Vite variables.
- The admin UI checks the signed-in user's UUID against `admin_profiles`; RLS policies enforce access on the database and storage.
- Public users can read published products and categories; owner-only policies control writes and unpublished product access.
- Product images are public-read and owner-write, as configured in the supplied SQL.
- WhatsApp links are intercepted on native Android and opened through Capacitor Browser; on the website they remain normal links.

## Build verification status (2026-11-18)

This delivery is **not an APK**. The supplied ZIP contains the React/Vite source, Capacitor configuration, branding artwork and build scripts, but it does not contain a generated `android/` directory. An attempt to install dependencies in the build environment failed because `registry.npmjs.org` could not be resolved (DNS/network unavailable); offline installation also confirmed the required Capacitor packages are not cached. No Android SDK, `adb`, `sdkmanager`, or Gradle executable is configured in that environment. Therefore `cap add android`, Gradle compilation, APK validation, and device testing were not performed. No APK is claimed to have been generated.

The existing `package-lock.json` predates the Capacitor dependencies listed in `package.json`. On a machine with npm registry access, run `npm install` first to refresh the lockfile, then follow section 4 to generate the Android project. The `.env` file was not present in the supplied ZIP and has not been created or modified.
