# My Boji update status

## Implemented in this source package

- Split purchase inquiries (`+963 988 913 578`) from seller contact (`+963 937 306 331`).
- Removed category creation/management from the owner dashboard while keeping car/motorcycle type selection.
- Added new/used condition filtering that composes with vehicle type and text search.
- Added the orange `جديد` badge on product cards and details.
- Added multi-image owner upload/edit controls and a normalized `product_images` gallery table migration with legacy `image_url` backfill.
- Added product gallery thumbnails and a full-screen image viewer with zoom controls, wheel zoom, pan, and multi-pointer pinch zoom.
- Updated the website favicon and Android icon source assets from the official supplied B/spark-plug mark; retained the full official logo and splash artwork.
- Added a persistent light/dark theme toggle and dark palette overrides.
- Added a GitHub Actions Android debug-APK build workflow and artifact/release upload steps.

## Required before production use

1. Apply `supabase/migrations/202611200001_product_image_gallery.sql` in the existing Supabase project.
2. Add GitHub Actions repository secrets `VITE_SUPABASE_URL` and either `VITE_SUPABASE_ANON_KEY` or `VITE_SUPABASE_PUBLISHABLE_KEY`. Never use a service-role key.
3. Install dependencies with `npm install` once to refresh the inherited lockfile; the existing lockfile predates the Capacitor dependencies. The CI workflow uses `npm install` for this reason.
4. Run the `Build My Boji Android APK` GitHub Actions workflow. It creates/synchronizes the native Android project, generates Android launcher/splash assets, builds a debug APK, and uploads `My-Boji.apk` as an Actions artifact.

## Verification performed in this environment

- TypeScript/TSX transpilation syntax checks: passed (no syntax diagnostics).
- CSS brace-balance check: passed.
- GitHub Actions YAML parse: passed.
- ZIP archive integrity: passed.
- Contact route and category-management source scans: passed.

## Not verified / not completed here

- Full TypeScript type-check and Vite production build: not run successfully because npm dependencies are not installed and the npm registry is unreachable from this environment.
- Android native project generation, Gradle compilation, APK archive verification, emulator/device testing: not run; Android SDK/Gradle build environment is unavailable here.
- GitHub repository inspection, commit, push, or Actions run: not performed because GitHub access is not connected in this session.
- Real Supabase authentication, RLS, Storage upload, and live product-gallery testing: not performed against the user's private backend.
