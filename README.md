# My Boji — owner store application

Arabic-first RTL storefront and single-owner product administration for the Syrian market. Customers browse published stock and contact the store through WhatsApp (+963937306331). There is no seller registration or customer account system.

## Included
- Responsive Arabic storefront; public catalog loads from Supabase (no demo products).
- Product search and car/motorcycle category filtering.
- Product detail view and prefilled WhatsApp inquiry links.
- Supabase email/password owner sign-in.
- Owner allow-list via `admin_profiles`; admin UI refuses access unless the signed-in user's UUID is on that table.
- Product create/edit/delete, stock, publication status, category type, product image upload.
- Category management.
- PostgreSQL schema, indexes, RLS policies and public product image bucket policies in `supabase/schema.sql`.

## 1. Supabase setup (required once)
1. Create a Supabase project.
2. Open SQL Editor and run the entire `supabase/schema.sql` file.
3. Open Authentication → Users → Add user → Create user. Create your owner account. Disable public sign-ups in Authentication settings.
4. Copy the owner's UUID from Authentication → Users.
5. In SQL Editor run (replace the UUID):
   ```sql
   insert into public.admin_profiles (user_id) values ('OWNER-USER-UUID');
   ```
   This allow-list step is essential. Authentication alone does not grant admin privileges.
6. Copy Project URL and the publishable/anon public key from Project Settings → API Keys.

## 2. Configure the app
Create `.env` in the project root (same level as `package.json`):
```env
VITE_SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_PUBLIC_KEY
```
Do not use the database password, service_role key, or secret key here. `.env` is gitignored. Restart the dev server after changing it.

## 3. Run
Node.js 20.19+ or 22.12+ recommended.
```bash
npm install
npm run dev
```
Open the local Vite URL. Owner panel: append `#owner` (for example `http://localhost:5173/#owner`).

## 4. Deploy
Deploy the Vite project to Netlify or Vercel. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` as build environment variables in the host dashboard, then redeploy. Configure your custom domain and HTTPS at the host. Supabase public URL/key are expected client-side; all data access is constrained by RLS. Never deploy a service-role key.

## Security notes
- RLS is enabled on products, categories and admin_profiles.
- Public users can only read published products and public categories.
- Only a user explicitly added to `admin_profiles` can write products/categories or manage product images.
- Product images are public-read, owner-write. Do not upload private/customer images.
- The app's owner check is a convenience gate; database RLS is the actual security boundary.
- No payment processing, shipping promises, seller accounts, or online checkout are implemented.

## Build verification
Run `npm run build` before deployment. Confirm public catalog reads work, a non-owner cannot access admin actions, owner can CRUD products, and public users cannot read unpublished products.
