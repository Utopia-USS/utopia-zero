# Pilot #1 - Wślizgnij To! (poc-janek, P001, 2026-08-18 → w toku)

Pierwszy przebieg z PRAWDZIWYM laikiem - to jest test hipotezy głównej (osoba
nietechniczna dochodzi do rozwijalnego POC bez interwencji operatora), którego
dry-runy [#1](DRYRUN-FINDINGS.md) i [#2](ZATOCZENIE-FINDINGS.md) tylko udawały.

Kontekst: tryb Zero (nigdy nie programował), Windows, słaby sprzęt (i5-2400 z 2011,
4 rdzenie, 16 GB RAM), aplikacja desktop bez `claude` CLI → wizard w trybie
plugin-less (klon w `zero/.wizard`), Opus 5 High na planie Pro. Projekt: gra
imprezowa "Wślizgnij To!" (frazy wplatane w rozmowę).

**Ten dokument jest przyrostowy** - pilot trwa, obserwacje dopisujemy falami.
Stan na 2026-08-20: etapy 0-2 zamknięte w dwa wieczory (18-19.08), etap 3
(szkielet) rozpoczęty. BRIEF i 3 makiety zaakceptowane za pierwszym podejściem,
bramki (`flutter analyze`, `utopia doctor`) czyste, pierwszy build weba 240 s i
udany za 1. próbą. Pulse #1: kontrola 5/5, jasność 5/5.

## Naprawione w trakcie, przed tą falą (osobne PR-y)

- **Zła aplikacja** (plain Claude zamiast Claude Code) - to była przyczyna źródłowa
  pierwszego wieczoru: brak push, brak zapisu `.claude/settings.json`, brak
  `/plugin` i CLI. Wykrywanie + prowadzenie do właściwej aplikacji: PR #29
  (reguła 1b w CLAUDE.md startera).
- **Popup instalacji pluginów nie pojawia się** na części desktopów - tryb
  plugin-less (klon publicznego repo) jako pełnoprawna ścieżka: PR #27/#28.
- **Sync skryptów analitycznych v2** do istniejących repo uczestników - wszedł
  operacyjnie 2026-08-19 (commit operatora w poc-janek); mechanizm VERSION
  zadziałał zgodnie z designem ("sync niepotrzebny" po stronie wizarda).

## Fala 1 - do naprawy w pluginie/starterze

1. **Generator lokalizacji z arkusza blokuje codegen świeżego scaffoldu.**
   `utopia create` zostawia `utopia_localization_generator` spięty z placeholderowymi
   id arkusza (DOCID/SHEETID); codegen pobrał stronę błędu HTML i wpiekł ją w
   `app_localizations`, zatrzymując build. Przewodnik zaimprowizował dobrze (wyciął
   generator, teksty PL inline, `decision{area:"localization"}`), ale wejdzie w to
   każdy kolejny uczestnik. → stages.md etap 2: usunięcie generatora TUŻ PO
   scaffoldzie jako standard jednojęzycznego POC. **[naprawione w tej fali]**
   Docelowo do naprawy także w samym scaffoldzie `utopia_cli` (inne repo).
2. **`.ps1` gubi cudzysłowy JSON-a przy wywołaniu przez zagnieżdżony PowerShell.**
   `log_event.ps1 <type> '<json>'` odpalany z sesji wizarda psuje payload; Git Bash
   + `log_event.sh` działa bez zarzutu, a Git Bash jest na Windows gwarantowany
   (git to wymaganie etapu 0/2). → analytics.md + CLAUDE.md startera: na Windows
   preferuj `bash zero/scripts/log_event.sh`, `.ps1` tylko bez dostępnego basha.
   **[naprawione w tej fali]**
3. **Hooki SessionStart/End w ogóle się nie odpalają (Windows desktop app).**
   Wpis w `.claude/settings.json` poprawny, skrypty sprawne (ręcznie działają),
   2 restarty - zero `session_start`. Exit etapu 0 ("hooks confirmed live") nie
   miał ścieżki awaryjnej; przewodnik zaimprowizował ręczną dyspozycję (sam odpala
   hook-skrypty na wejściu i wyjściu sesji). → stages.md etap 0 + analytics.md:
   ręczna dyspozycja jako oficjalny fallback po DWÓCH nieudanych restartach, ze
   świeżym `session_id` per sesja, wpisem `hooks: manual dispatch` w STATE i
   jednorazowym `error{category:"hooks"}`. **[naprawione w tej fali - fallback
   skodyfikowany; przyczyna martwego dispatchu dalej nieznana, patrz niżej]**

## Do zbadania / kandydaci na falę 2

4. **Dlaczego dispatch hooków nie działa na Windows desktop?** Skrypty wykluczone
   (v2, sprawne ręcznie), JSON w settings poprawny. Wymaga reprodukcji na maszynie
   z Windows albo przeglądu znanych issues Claude Code.
5. **Regex reconciliacji `.stage` nigdy nie pasuje do szablonu STATE.**
   `hook_session_start` greppuje `Etap ?/ ?Stage: ?\*\*[0-9]+` (pogrubienie), a
   szablon startera i STATE Janka piszą `- Etap / Stage: 3` bez gwiazdek → mechanizm
   z dry-runu #2 jest martwy na każdym repo. Zamaskowane, bo `stage_start` i tak
   zapisuje `.stage` wprost. Naprawa = skrypty v3 (`.sh` + `.ps1`) + bump VERSION,
   więc osobna fala. **[naprawione w fali 2 - skrypty v3: regex dopuszcza 0-2
   gwiazdki; oba formaty + przypadki brzegowe przetestowane w sandboksie na `.sh`]**
6. **Artefakt danych: wszystkie eventy poc-janek mają `session_id: "s0"`.**
   Hooki nigdy nie zapisały `.session`, a `log_event` bierze stąd id (fallback
   `s0`). Analizy pilota #1 muszą segmentować sesje po odstępach czasu, nie po
   `session_id`; reguła "ostatni snapshot per session_id" dla tokenów nie ma na
   tym repo sensu do momentu wejścia fallbacku ze świeżymi id (pkt 3).

## Obserwacje bez akcji (na razie)

- **Słaby sprzęt obsłużony zgodnie z designem**: decyzja `preview-target: lan`
  (emulator odrzucony na 4-rdzeniowym i5 z 2011) podjęta samodzielnie, bez
  angażowania użytkownika, z rationale w evencie. Etap 5 pozostaje opcjonalny.
- **Dyktowanie**: Win+H nie działa dla polskiego na tej maszynie (3 próby naprawy,
  w tym online speech recognition). Użytkownik pisze; aplikacja whisperowa (Handy)
  zaproponowana i odłożona na jego życzenie. Krok 4a zachował się jak w designie -
  rekomendacja, nie wymóg; temat wraca tylko z inicjatywy użytkownika.
- **Zagnieżdżony folder** `poc-janek\poc-janek` po rozpakowaniu ZIP-a - kosmetyka;
  rozważyć jedno zdanie w onboardingu ("otwórz folder wewnętrzny").
- **Kanał aktualizacji działa**: wizard plugin-less robi `git pull` przewodnika na
  starcie sesji, więc poprawki z tej fali dotrą do pilota bez interwencji.
- **Sygnał do obejrzenia w etapie 3**: obowiązkowy checkpoint szkieletu ("mapa
  aplikacji") - pierwszy moment, w którym laik konfrontuje strukturę całej
  aplikacji z własną wizją.
