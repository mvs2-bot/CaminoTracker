-- =====================================================================
-- CaminoTracker: Lesezugriff für freigeschaltete Konten
-- Wer in der Verwaltung für caminotracker mindestens "Mitglied" ist
-- (oder globaler Admin), darf Stefans Wege, Etappen und Unterkünfte ansehen.
-- Schreiben bleibt beim Eigentümer-Konto (Policy *_owner aus 001).
-- =====================================================================
begin;

create or replace function public.camino_can_view()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select public.camino_is_owner() or public.overall_has_app_role('caminotracker', 'member');
$$;
revoke all on function public.camino_can_view() from public, anon;
grant execute on function public.camino_can_view() to authenticated;

do $$
declare t text;
begin
    foreach t in array array['camino_routes', 'camino_stages', 'camino_stays'] loop
        execute format('drop policy if exists %I on public.%I', t || '_view', t);
        execute format($p$create policy %I on public.%I for select to authenticated
            using ((select public.camino_can_view()))$p$, t || '_view', t);
    end loop;
end $$;

commit;
