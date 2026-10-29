-- =====================================================================
-- Camino Tracker – Schema für das Supabase-Projekt "core"
-- ---------------------------------------------------------------------
-- Tabellen mit App-Präfix camino_*. Strikt privat: Zugriff hat genau EIN Konto
-- (Stefan, fest verdrahtet in camino_is_owner()). Kein Admin-Bypass, keine
-- Freischaltung über overall_app_access – andere Admins sehen nichts.
--
-- Idempotent, kann im SQL-Editor erneut ausgeführt werden.
-- =====================================================================

begin;

-- ---------------------------------------------------------------------
-- 1. Zugriffsprüfung: nur das Eigentümer-Konto
-- ---------------------------------------------------------------------
create or replace function public.camino_is_owner()
returns boolean
language sql
stable
security definer
set search_path to ''
as $$
    select (select auth.uid()) = 'c41729ca-110b-4b0c-9c77-29ca1a09a23e'::uuid;
$$;

revoke all on function public.camino_is_owner() from public, anon;
grant execute on function public.camino_is_owner() to authenticated;

-- ---------------------------------------------------------------------
-- 2. Tabellen
-- ---------------------------------------------------------------------
-- Eine gelaufene Route (z. B. Camino Primitivo 2023). Track = GeoJSON MultiLineString aus GPX.
create table if not exists public.camino_routes (
    id            uuid        primary key default gen_random_uuid(),
    user_id       uuid        not null default auth.uid() references auth.users (id) on delete cascade,
    name          text        not null check (char_length(name) between 1 and 120),
    start_place   text        check (char_length(start_place) <= 120),
    end_place     text        check (char_length(end_place) <= 120),
    start_date    date,
    end_date      date,
    distance_km   numeric(7,2) check (distance_km is null or distance_km between 0 and 20000),
    ascent_m      integer     check (ascent_m is null or ascent_m between 0 and 1000000),
    color         text        not null default '#c2410c' check (color ~ '^#[0-9a-fA-F]{6}$'),
    notes         text        check (char_length(notes) <= 4000),
    track         jsonb       check (track is null or (jsonb_typeof(track) = 'object' and pg_column_size(track) <= 3000000)),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now(),
    constraint camino_routes_dates_chk check (end_date is null or start_date is null or end_date >= start_date)
);
comment on table public.camino_routes is 'Camino Tracker: gelaufene Routen inkl. GPX-Track (GeoJSON). Strikt privat (nur Eigentümer).';
create index if not exists camino_routes_user_idx on public.camino_routes (user_id, start_date desc);

-- Tagesetappe einer Route
create table if not exists public.camino_stages (
    id            uuid        primary key default gen_random_uuid(),
    user_id       uuid        not null default auth.uid() references auth.users (id) on delete cascade,
    route_id      uuid        not null references public.camino_routes (id) on delete cascade,
    stage_date    date        not null,
    from_place    text        check (char_length(from_place) <= 120),
    to_place      text        check (char_length(to_place) <= 120),
    distance_km   numeric(6,2) check (distance_km is null or distance_km between 0 and 300),
    notes         text        check (char_length(notes) <= 2000),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);
comment on table public.camino_stages is 'Camino Tracker: Tagesetappen einer Route. Strikt privat (nur Eigentümer).';
create index if not exists camino_stages_route_idx on public.camino_stages (route_id, stage_date);

-- Unterkunft (Datum ist Pflicht)
create table if not exists public.camino_stays (
    id            uuid        primary key default gen_random_uuid(),
    user_id       uuid        not null default auth.uid() references auth.users (id) on delete cascade,
    route_id      uuid        references public.camino_routes (id) on delete set null,
    stay_date     date        not null,
    name          text        not null check (char_length(name) between 1 and 160),
    place         text        check (char_length(place) <= 120),
    kind          text        not null default 'albergue'
                              check (kind in ('albergue', 'hostel', 'pension', 'hotel', 'casa_rural', 'other')),
    price_eur     numeric(7,2) check (price_eur is null or price_eur between 0 and 10000),
    rating        smallint    check (rating is null or rating between 1 and 5),
    lat           double precision check (lat is null or lat between -90 and 90),
    lng           double precision check (lng is null or lng between -180 and 180),
    notes         text        check (char_length(notes) <= 2000),
    created_at    timestamptz not null default now(),
    updated_at    timestamptz not null default now()
);
comment on table public.camino_stays is 'Camino Tracker: Unterkünfte mit Datum der Übernachtung. Strikt privat (nur Eigentümer).';
create index if not exists camino_stays_user_idx on public.camino_stays (user_id, stay_date desc);
create index if not exists camino_stays_route_idx on public.camino_stays (route_id);

-- updated_at pflegen (Hilfsfunktion aus "core")
drop trigger if exists camino_routes_touch on public.camino_routes;
create trigger camino_routes_touch before update on public.camino_routes for each row execute function public.overall_touch_updated_at();
drop trigger if exists camino_stages_touch on public.camino_stages;
create trigger camino_stages_touch before update on public.camino_stages for each row execute function public.overall_touch_updated_at();
drop trigger if exists camino_stays_touch on public.camino_stays;
create trigger camino_stays_touch before update on public.camino_stays for each row execute function public.overall_touch_updated_at();

-- ---------------------------------------------------------------------
-- 3. Row Level Security: eigene Zeilen UND Eigentümer-Konto
-- ---------------------------------------------------------------------
do $$
declare t text;
begin
    foreach t in array array['camino_routes', 'camino_stages', 'camino_stays'] loop
        execute format('alter table public.%I enable row level security', t);
        execute format('alter table public.%I force row level security', t);
        execute format('revoke all on table public.%I from anon', t);
        execute format('revoke truncate, references, trigger on table public.%I from authenticated', t);
        execute format('grant select, insert, update, delete on table public.%I to authenticated', t);
        execute format('drop policy if exists %I on public.%I', t || '_owner', t);
        execute format($p$create policy %I on public.%I for all to authenticated
            using (user_id = (select auth.uid()) and (select public.camino_is_owner()))
            with check (user_id = (select auth.uid()) and (select public.camino_is_owner()))$p$, t || '_owner', t);
    end loop;
end $$;

commit;
