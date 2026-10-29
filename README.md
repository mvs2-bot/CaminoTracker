# Camino Tracker

Private Übersicht der gelaufenen Jakobswege: Kennzahlen, Karte mit GPX-Tracks, Etappen und Unterkünfte.
Modul im Dashboard [mvs2-bot.github.io](https://mvs2-bot.github.io/), läuft direkt auf GitHub Pages unter `/CaminoTracker/`.

| Datei | Inhalt |
| --- | --- |
| `index.html` | Komplette App: HTML, CSS (Apple-Designsprache wie DailyMind), Alpine.js, supabase-js, Leaflet. |
| `supabase/001_camino_schema.sql` | Tabellen `camino_routes`, `camino_stages`, `camino_stays`, RLS. |
| `shared/ios-nav.js` | Kopie aus dem Dashboard-Repo (Zurück/Neu laden in installierten iOS-Web-Apps). |

## Sicherheit

- Supabase-Projekt „core“. RLS aktiv und erzwungen, `anon` ohne Rechte.
- Jede Policy prüft `user_id = auth.uid()` **und** `camino_is_owner()`: die UUID des Eigentümer-Kontos ist fest
  in der Funktion hinterlegt. Kein Admin-Bypass, keine Freischaltung über `overall_app_access`.
- Anderes Konto: App zeigt „Privat“, Datenbank liefert nichts.

## Bedienung

- **Übersicht:** Gesamtkilometer, Caminos, Wandertage, Nächte, Höhenmeter, längste Etappe, Routenkarten.
- **Route:** Eine oder mehrere GPX-Dateien hochladen (z. B. eine pro Tag). Distanz, Höhenmeter, Zeitraum und Track
  werden berechnet; aus den Zeitstempeln entstehen auf Wunsch Tagesetappen. Track wird vereinfacht als GeoJSON gespeichert.
- **Karte:** Alle Tracks und Unterkünfte, Filter je Route. Kacheln: CARTO (hell/dunkel).
- **Unterkünfte:** Datum der Übernachtung ist Pflicht. Position per Tipp auf die Mini-Karte.
