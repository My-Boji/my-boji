-- Safe, additive product gallery migration for My Boji.
-- Keeps products.image_url as the legacy/primary cover URL for older clients.
create table if not exists public.product_images (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete cascade,
  image_url text not null,
  sort_order integer not null default 0 check (sort_order >= 0),
  created_at timestamptz not null default now(),
  unique (product_id, sort_order)
);

create index if not exists product_images_product_order_idx on public.product_images(product_id, sort_order);
alter table public.product_images enable row level security;

drop policy if exists "public reads published product galleries" on public.product_images;
create policy "public reads published product galleries" on public.product_images
  for select to anon, authenticated using (
    exists (select 1 from public.products p where p.id = product_images.product_id
      and (p.is_published = true or public.is_store_owner()))
  );

drop policy if exists "owner manages product galleries" on public.product_images;
create policy "owner manages product galleries" on public.product_images
  for all to authenticated using (public.is_store_owner()) with check (public.is_store_owner());

grant select on public.product_images to anon, authenticated;
grant insert, update, delete on public.product_images to authenticated;

-- Backfill legacy single-image products without overwriting existing gallery rows.
insert into public.product_images(product_id, image_url, sort_order)
select p.id, p.image_url, 0 from public.products p
where p.image_url is not null and length(trim(p.image_url)) > 0
  and not exists (select 1 from public.product_images pi where pi.product_id = p.id)
on conflict (product_id, sort_order) do nothing;
