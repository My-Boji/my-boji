-- My Boji production schema. Run once in Supabase SQL Editor as project owner.
create extension if not exists pgcrypto;
create table if not exists public.admin_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type text not null check (type in ('car','motorcycle')),
  created_at timestamptz not null default now(),
  unique(name,type)
);
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 180),
  slug text not null unique,
  description text not null default '',
  category_id uuid references public.categories(id) on delete set null,
  category_type text not null check (category_type in ('car','motorcycle')),
  make text not null default '',
  model text not null default '',
  year text not null default '',
  price numeric(14,2) not null default 0 check (price >= 0),
  currency text not null default 'SYP' check (currency = 'SYP'),
  condition text not null default 'جديد' check (condition in ('جديد','مستعمل')),
  sku text not null default '',
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  is_published boolean not null default false,
  is_featured boolean not null default false,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists products_public_catalog_idx on public.products(is_published, created_at desc);
create index if not exists products_search_idx on public.products using gin (to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(sku,'') || ' ' || coalesce(make,'') || ' ' || coalesce(model,'')));
create index if not exists products_category_idx on public.products(category_type, make, model, year);

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at before update on public.products for each row execute function public.set_updated_at();

create or replace function public.is_store_owner() returns boolean language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.admin_profiles where user_id = auth.uid());
$$;
revoke all on function public.is_store_owner() from public;
grant execute on function public.is_store_owner() to anon, authenticated;

alter table public.admin_profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
drop policy if exists "owner reads own admin profile" on public.admin_profiles;
create policy "owner reads own admin profile" on public.admin_profiles for select to authenticated using (user_id = auth.uid());
drop policy if exists "public reads categories" on public.categories;
create policy "public reads categories" on public.categories for select to anon, authenticated using (true);
drop policy if exists "owner manages categories" on public.categories;
create policy "owner manages categories" on public.categories for all to authenticated using (public.is_store_owner()) with check (public.is_store_owner());
drop policy if exists "public reads published products" on public.products;
create policy "public reads published products" on public.products for select to anon, authenticated using (is_published = true or public.is_store_owner());
drop policy if exists "owner manages products" on public.products;
create policy "owner manages products" on public.products for all to authenticated using (public.is_store_owner()) with check (public.is_store_owner());

grant select on public.categories, public.products to anon, authenticated;
grant insert, update, delete on public.categories, public.products to authenticated;
grant select on public.admin_profiles to authenticated;

-- Storage: public product images, owner-only upload/update/delete.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('product-images','product-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true, file_size_limit=5242880, allowed_mime_types=array['image/jpeg','image/png','image/webp'];
drop policy if exists "public reads product images" on storage.objects;
create policy "public reads product images" on storage.objects for select to anon, authenticated using (bucket_id='product-images');
drop policy if exists "owner uploads product images" on storage.objects;
create policy "owner uploads product images" on storage.objects for insert to authenticated with check (bucket_id='product-images' and public.is_store_owner());
drop policy if exists "owner updates product images" on storage.objects;
create policy "owner updates product images" on storage.objects for update to authenticated using (bucket_id='product-images' and public.is_store_owner()) with check (bucket_id='product-images' and public.is_store_owner());
drop policy if exists "owner deletes product images" on storage.objects;
create policy "owner deletes product images" on storage.objects for delete to authenticated using (bucket_id='product-images' and public.is_store_owner());

-- IMPORTANT: After creating the owner in Authentication > Users, copy that user's UUID
-- and run this statement separately to grant owner access:
-- insert into public.admin_profiles (user_id) values ('PASTE-AUTH-USER-UUID-HERE');
-- Never expose the service_role key in the browser.
