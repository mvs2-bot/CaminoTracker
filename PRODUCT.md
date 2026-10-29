# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users
Ein Nutzer: Stefan, Pilger auf mehreren Jakobswegen (Camino Francés, Primitivo, Portugiesischer Weg ab Porto u. a.). Öffnet die App am Handy oder Rechner, um gelaufene Wege nachzuerfassen und zurückzublicken.

## Product Purpose
Private Übersicht über abgeschlossene Caminos: Gesamtkilometer und Statistik, gelaufene Tracks auf einer Karte, Etappen und ein Logbuch der Unterkünfte mit genauem Übernachtungsdatum. Erfolg: alle Wege vollständig erfasst und auf einen Blick erlebbar.

## Positioning
Kein Planungs- oder Social-Tool: ein persönliches, abgeschlossenes Pilgerarchiv aus echten GPX-Tracks, nur für den Eigentümer.

## Operating Context
Modul im privaten Dashboard mvs2-bot.github.io (Apps im selben Look: DailyMind, TravelBase, Quest Log). Login über Supabase „core“, Hell/Dunkel über gemeinsamen Schlüssel `overall-theme`. Daten kommen per GPX-Upload (oft eine Datei pro Tag) und manueller Eingabe.

## Capabilities and Constraints
- Statisches HTML auf GitHub Pages, Alpine.js, supabase-js, Leaflet; kein Build-Schritt.
- Daten strikt privat (RLS, nur Eigentümer-UUID).
- Pflicht: Datum je Unterkunft. Dark Mode, vollständig responsiv.

## Brand Commitments
Name „Camino Tracker“. Vorgabe des Nutzers: sauber, modern, minimalistisch, abenteuerlich, kartenbasiert; inspiriert von Travelbase (Outdoor/Reise) und DailyMind (ruhig, hochwertig). Altes Muschel-Icon gefällt nicht.

## Evidence on Hand
Noch keine echten Daten erfasst; Beispieldaten in Tests sind synthetisch.

## Product Principles
- Rückblick vor Verwaltung: Erinnerung sichtbar machen, Eingabe schnell halten.
- Echte Spuren statt Deko: Tracks und Orte tragen die Gestaltung.
- Privat und ruhig, ohne Social- oder Gamification-Lärm.
