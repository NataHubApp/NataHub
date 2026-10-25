-- NataHub database schema for Supabase
-- Run this script in Supabase SQL Editor before connecting the website.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  business_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  sku text not null,
  category text not null default 'Lainnya',
  quantity integer not null default 0 check (quantity >= 0),
  min_stock integer not null default 0 check (min_stock >= 0),
  unit text not null default 'pcs',
  location text not null default '',
  price numeric(14,2) not null default 0 check (price >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, sku)
);

create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete cascade,
  type text not null check (type in ('in','out')),
  quantity integer not null check (quantity > 0),
  reason text not null default '',
  notes text not null default '',
  created_at timestamptz not null default now()
);

create index if not exists products_user_name_idx on public.products(user_id, name);
create index if not exists products_user_category_idx on public.products(user_id, category);
create index if not exists movements_user_created_idx on public.stock_movements(user_id, created_at desc);
create index if not exists movements_product_idx on public.stock_movements(product_id);

alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.stock_movements enable row level security;

drop policy if exists "profiles select own" on public.profiles;
create policy "profiles select own" on public.profiles for select using (auth.uid() = id);
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "products select own" on public.products;
create policy "products select own" on public.products for select using (auth.uid() = user_id);
drop policy if exists "products insert own" on public.products;
create policy "products insert own" on public.products for insert with check (auth.uid() = user_id);
drop policy if exists "products update own" on public.products;
create policy "products update own" on public.products for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "products delete own" on public.products;
create policy "products delete own" on public.products for delete using (auth.uid() = user_id);

drop policy if exists "movements select own" on public.stock_movements;
create policy "movements select own" on public.stock_movements for select using (auth.uid() = user_id);
drop policy if exists "movements insert own" on public.stock_movements;
create policy "movements insert own" on public.stock_movements for insert with check (auth.uid() = user_id and exists (select 1 from public.products p where p.id = product_id and p.user_id = auth.uid()));
drop policy if exists "movements delete own" on public.stock_movements;
create policy "movements delete own" on public.stock_movements for delete using (auth.uid() = user_id);

-- Automatically create a profile after signup.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, business_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name',''),
    coalesce(new.raw_user_meta_data->>'business_name','')
  ) on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
