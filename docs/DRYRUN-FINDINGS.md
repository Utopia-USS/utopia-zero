# Dry-run #1 — obserwacje (Paplanina, poc-dryrun, 2026-08-04/05)

Tryb kanapowy (maszyna operatora, remote SSH, bez PAT). Uczestnik: Paweł grający laika.
Przebieg: Etapy 0→6 w jeden wieczór; MVP (5 funkcji) + handover; brak eskalacji.

## Audyt zewnętrzny handoveru (rola: deweloper przejmujący; z CZYSTEGO klona GitHub)

**Wynik: 19/20** (samoocena wizarda: 20/20 — zawyżona o higienę repo).

- analyze 0 issues · `utopia doctor` 0/0/0 · SSV wzorcowe (screen/state/view) → 2+2+2+2
- **repo hygiene 1/2**: `.idea/` (5 plików) w HEAD — jedyny punkt odjęty
- BRIEF/DECISIONS/HANDOVER kompletne, HANDOVER uczciwy („backend celowo nieużyty",
  „mobile not exercised") → 2+2 (docs, todos)
- zależności zdrowe → 2 · **clean-clone run zweryfikowany na żywo** (pub get → run →
  przeklikana gra: welcome → kategorie → karta + Pomiń/Dalej) → 2
- **testy 2/2**: 4 realne testy zachowań (no-repeat po restarcie, reshuffle po
  wyczerpaniu, przełączanie talii, persystencja edycji) — wszystkie przechodzą
- poprawki z checkpointu użytkownika (ikona zamiast emoji-tofu, kontrast przycisku)
  potwierdzone wizualnie w klonie

**Werdykt miary #1 (rozwijalność): POZYTYWNY** — projekt przejmowalny przez zespół
bez kontaktu z autorem: odpala się z klona wg samego HANDOVER-a, bramki czyste,
decyzje udokumentowane. Metodologiczna uwaga: uczestnikiem był programista grający
laika na nie-czystej maszynie — pilot z prawdziwym laikiem pozostaje właściwym testem.

## Do naprawy w pluginie/starterze (kandydaci na PR)

1. **Rework bez śladu w analityce** — poprawki ekranu powitalnego zgłoszone przez
   użytkownika (emoji-tofu + kontrast przycisku) zostały wykonane, ale nie zostawiły
   ŻADNEGO eventu (`checkpoint{rework}` / `error`). Badanie „rozjazd wizja↔implementacja"
   traci sygnał. → stages.md/analytics.md: obowiązek logowania `checkpoint{feature,
   verdict:"change", rework:n}` przy KAŻDEJ poprawce zgłoszonej przez użytkownika.
2. **Niedologowany wywiad (etap 1)** — odpowiedzi `idea` i `mechanics-success` bez
   sparowanych eventów `question`; w etapie 4 para była kompletna. → analytics.md:
   twarda reguła „każde pytanie loguj PRZED zadaniem".
3. **`.idea/` w repo** — wizard commitnął artefakty IDE (operator zajrzał IntelliJ-em).
   → starter/.gitignore: dodać `.idea/`, `.vscode/`, `*.iml`; stages.md: wizard nie
   commituje plików spoza swojej pracy bez powodu (git add ścieżkami, nie `-A`).
4. **Emoji na webie** — `Text('🎉')` wyrenderował się jako tofu (Flutter web bez
   fontu emoji). → design-interview.md: reguła „ikony Material/assety zamiast surowych
   emoji w UI (web-first!)".
5. **Kontrast poniżej własnego progu** — biały przycisk + jasnoróżowy tekst złamał
   wpisany w design-interview.md próg 4.5:1. → stages.md etap 2/6: kontrast jako
   CHECK (samokontrola przed pokazaniem ekranu), nie tylko zasada w prozie.
6. **Podgląd nieodświeżony po poprawce** — użytkownik patrzył na stary bundle
   (agresywny cache Flutter web). → stages.md: po każdej poprawce wizualnej hot-restart
   + komunikat „odśwież stronę (Cmd+Shift+R)" gdy user sam się podgląda.
7. **Kolejność feature_done vs commit** — event leci przed commitem. → analytics.md:
   `feature_done` PO commicie (spójność danych z gitem).
8. **STATE w połowie etapu 0** — tryb/język nieznane w STATE do końca etapu; padnięcie
   sesji w połowie = utrata odpowiedzi. → stages.md: aktualizuj STATE natychmiast po
   mode/language/consent.

## Uzupełnienie po testach końcowych (2026-08-10)

- **Zaliczone w praniu**: „kontynuuj" po 6 dniach przerwy (powrót w idealne miejsce,
  samodzielne dopchnięcie zaległych pushy); opt-out/opt-in analityki (consent:false →
  aktywność bez śladu → consent:true, czyste commity obu przełączeń); uczciwe
  `survey{skipped by user}` przy pominiętej ankiecie.
- **12. Ankieta zebrana, niezalogowana** — powtórzona ankieta końcowa nie wygenerowała
  eventu ani aktualizacji STATE (wymagane dopiero po jawnym poleceniu użytkownika).
  Ten sam wzorzec co (2); reguły twarde już są — patrz następny punkt.
- **13. Długożyjące sesje nie widzą poprawek skilla** — sesja wizarda z 4.08 działała
  ze starą wersją references mimo merge'a poprawek 5.08 (marketplace ścieżkowy czyta
  na żywo, ale kontekst sesji nie). Wniosek operacyjny do pilota: po każdej
  aktualizacji pluginu sugerować świeżą sesję („zamknij i napisz: kontynuuj").
- **14. Polaryzacja skal ankiet** — payload `survey` nie mówi, czy 5 znaczy „dużo
  frustracji" czy „brak frustracji". Reguła do analytics.md przy następnym PR:
  wszystkie skale normalizowane do „wyżej = lepiej" (pytanie odwrócone → odwróć wynik
  przed zalogowaniem).
- **Edge-case opt-outu**: użytkownik wypełnił ankietę w oknie wyłączonej analityki →
  dane przepadły zgodnie z designem. Reguła do stages.md: czynność badawczo istotna
  przy wyłączonej analityce → jedno zdanie ostrzeżenia i pytanie, czy włączyć.

## Infra eksperymentu (v1.1, poza skillem)

9. Restart aplikacji generuje parę sesji startup(2s, pustą)+resume — filtrować po
   `source` w analizie; rozważyć pomijanie session_start/end dla sesji <10 s.
10. `session_end.models.in` łączy świeże tokeny i cache-ready (3,3M „in" za etap 0–1
    wygląda absurdalnie) — rozbić na `in`/`cache_read`/`cache_write` w parserach.
11. Transkrypt kopiuje się tylko na SessionEnd — długa sesja bez restartu = brak kopii
    do czasu zamknięcia; rozważyć okresową kopię (Stop hook?).

## Co zadziałało (do case study — nie ruszać)

- Detekcja panelu właściciela → dojrzałe ODRZUCENIE cms na rzecz ekranu w aplikacji
  (apka jednotelefonowa), z alternatywami w logu. Lepsze niż mechaniczne „wykryto→wciskam".
- Przynęta scope'owa („paczki od twórców") zaparkowana w Później z powodem
  (konta+płatności+backend); zmiana kategorii przez użytkownika (Pikantne→Filozoficzne,
  50+ pytań, trwały no-repeat) obsłużona i zalogowana jako `scope_request{done}`.
- MoSCoW ≤5 funkcji; „kategorie raz na start + szybki przełącznik" wiernie z odpowiedzi
  użytkownika; `user_override` przy nazwie (Iskra→Paplanina).
- Design: tokeny z wywiadu → ekran 1:1 (neon magenta/dark, Nunito, radius 20);
  samodzielna decyzja PL-only (usunięta lokalizacja) upraszczająca POC.
- Jakość decyzji technicznych wysoka (shuffled-deck z uzasadnieniem i alternatywami);
  3 funkcje à ~12 min, buildy za 1. podejściem, commity `feat: ... (tested)`.
- Infrastruktura: hooki e2e (session/usage/transcript/auto-push), fallback SSH bez
  PAT (PR #3) zadziałał, ankiety-puls (kontrola 4/5, jasność 5/5).

## Jeszcze nieprzetestowane (sesja 2 / przed pilotem)

- „kontynuuj" po pełnym zamknięciu · celowa awaria → drabinka 5 prób · eskalacja
  przez issue + podjęcie odpowiedzi (wymaga zatwierdzonego PAT!) · „wyłącz analitykę" ·
  etap 5 (LAN na telefon) · etap 6 (HANDOVER + rubryka) · czysta maszyna + auto-install
  prompt · Windows (.ps1 w praniu).
