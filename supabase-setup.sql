-- Run this ONCE in Supabase: SQL Editor -> New query -> paste -> Run.
-- It is safe to run again. It serves Praise & Worship, Echoes of Worship and Joseph Generation.

create table if not exists public.docs (
  collection text not null,
  id         text not null,
  data       jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (collection, id)
);

alter table public.docs enable row level security;
drop policy if exists "docs_open" on public.docs;
create policy "docs_open" on public.docs for all to anon, authenticated using (true) with check (true);

create or replace function public.docs_touch() returns trigger language plpgsql as $$
begin new.updated_at := now(); return new; end $$;
drop trigger if exists docs_touch on public.docs;
create trigger docs_touch before insert or update on public.docs
  for each row execute function public.docs_touch();

create or replace function public.pw_merge(c text, i text, d jsonb) returns void
language sql as $$
  insert into public.docs (collection, id, data) values (c, i, d)
  on conflict (collection, id) do update set data = public.docs.data || excluded.data;
$$;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.docs to anon, authenticated;
grant execute on function public.pw_merge(text, text, jsonb) to anon, authenticated;
