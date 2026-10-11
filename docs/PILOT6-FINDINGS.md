# Pilot #6 - Papla (poc-marcel → papla, P006, 2026-09-08 → 2026-09-25)

Przebieg insiderski: uczestnik jest programistą z Utopii i w etapie 0 wybrał
**tryb utopia** (STATE: "insider run - filter out of participant analyses").
macOS arm64, plan Max 5x, Opus 5 (1M), wizard w trybie plugin-less (klon `f7fbea8`,
skrypty v9). Analityka włączona, **transkrypty odrzucone** w etapie 0 (osobne
pytanie zadziałało: `consent{transcripts:false}` + `user_override` na fladze).
Zero issues `[zero]`.

Skala: ~265 commitów w 9 dni robocze, 188 zdarzeń, aplikacja Papla (gra imprezowa
na hasła, hot-seat + tryb online na Firebase), panel na utopia_cms, dwa podglądy
na Cloudflare Pages. Etapy 0-3 w dwa dni, potem etap 4 do końca.

Ponieważ przebieg jest insiderski, liczby nie wchodzą do porównań z laikami.
Wartość tego pilotażu jest gdzie indziej: to pierwszy projekt, który przeszedł
przez długi etap 4 (wiele dni, wiele sesji, migracja backendu) - i pokazał, co
się psuje w danych, kiedy projekt robi się duży.

## Co zadziałało

- **Etap 0-3 bez interwencji operatora**, hooki natywnie od pierwszej sesji
  (`session_end` z tokenami), pary `question`/`answer` domknięte (26/25).
- **Override'y logowane uczciwie**: rezygnacja z punktacji w MVP, suwak trudności
  zamiast trybów w taliach, świadome zejście z kontrastu 4.5:1 do 2.6:1 "po
  dwukrotnym zobaczeniu liczb" - każdy z `from`/`to`.
- **Scope requesty** obsłużone wg skryptu (Pracownia na życzenie, emoji graczy
  odłożone do BRIEF "Później" po wyjaśnieniu ograniczenia Flutter web).
- **Błędy treści łapane testem**: po drugim błędzie w taliach wizard dopisał test
  pilnujący trzech zasad treści dla każdej talii - dobry odruch, wart utrwalenia.

## Fala 1 - naprawione w tym PR (skrypty v10)

1. **Dziennik zdarzeń zamilkł po drugim dniu.** 09-09 i 09-10: 161 zdarzeń.
   09-11 → 09-25: **27 zdarzeń na ~140 commitów**, w tym dwie `decision` - przy
   migracji całego backendu z Supabase na Firebase, dopisaniu trybu online i
   dwóch deployach. `DECISIONS.md` urósł do 131 linii, dziennik tego nie widział.
   Zapis badawczy urywa się dokładnie tam, gdzie projekt robi się ciekawy.
   Przyczyna: obowiązek logowania blednie w długich sesjach (jedna sesja żyła
   od 09-09 do 09-14 przez resume i compact, kontekst 1M).
   → `hook_session_start` liczy commity (poza `zero: analytics`) od ostatniego
   zdarzenia semantycznego i przy **15+** wstrzykuje prośbę o nadrobienie
   (`note:"catch-up"`) i logowanie na bieżąco. Retrospektywnie na danych P006
   odpaliłby się 5 razy, każdorazowo w dniu ciszy (lag 16-50 commitów).
2. **Fantomowe sesje z CLI pluginów.** Naprawa zepsutej instalacji pluginów
   (`claude plugin …` z wnętrza sesji) zostawiła **pięć pustych `session_end`
   w jednej minucie** (`models_parsed:false`, bez `session_start`). Każde
   wywołanie CLI to osobna sesja, która odpala SessionEnd, ale nie SessionStart -
   bramka v9 (oparta na markerze `.pending`) jej nie widziała.
   → `hook_session_end`: brak markera + brak użycia tokenów + `session_id`
   nieobecne w `events.jsonl` = brak śladu. Prawdziwa sesja z markerem albo
   z wcześniejszymi zdarzeniami loguje się jak dotąd (sprawdzone).
3. **Przeterminowany cache marketplace'u.** Pluginy `utopia-flutter-skills`
   zadeklarowane w `settings.json`, ale nigdy nie zainstalowane (cache na starej
   wersji) - bez żadnego komunikatu. Wizard naprawił sam przez
   `claude plugin marketplace update` + install.
   → `stages.md` etap 0 krok 9: najpierw `marketplace update`, potem install.
4. **STATE przeczy sam sobie.** Na koniec: "Co działa" mówi, że projekt Firebase
   `papla-prod` działa, a "Następne kroki" pkt 1, że właściciel musi go dopiero
   założyć; "Znane luki" mówią, że funkcje nie są wdrożone, a dziennik z 09-25
   ma błąd zwrócony przez wdrożoną funkcję. Poprawka `df2001a` (wave 2) nie
   wystarczyła - STATE był dopisywany, a nie uzgadniany.
   → `stages.md` etap 4 krok 7: aktualizacja STATE = przejście "Następnych
   kroków" i "Znanych luk" i wykreślenie tego, co feature uczynił nieprawdą.
5. **Deploy zagłodzony przez `cancel-in-progress`.** Build ~3 min, push co ~2 min:
   sześć kolejnych runów anulowanych, podgląd stał, aż uczestnik zrobił przerwę.
   Pełny koszt minut Actions, zero publikacji.
   → `deploy-web.yml`: `cancel-in-progress: false`. GitHub trzyma w grupie
   jeden bieżący i jeden (najnowszy) oczekujący run, więc koszt jest ograniczony,
   a publikacja zawsze dochodzi.
6. **IDE + fvm w trybie Pro/Utopia.** Dwie rundy straty: pin fvm w korzeniu
   repo (plugin Fluttera go nie widział, IDE cofało SDK) i uruchomienie
   `main.dart` zwykłą konfiguracją Dart (crash kompilatora `InvalidType is not
   a subtype of type FunctionType`).
   → `stages.md` etap 2: pin w `app/.fvmrc`, IDE otwierane na `app/`,
   konfiguracja Flutter.

Przy okazji, niezależnie od P006: **Claude Code to teraz zakładka Code w jednej
aplikacji Claude** - onboarding (PL/EN), README, starter i reguła wykrywania
złej powierzchni w `starter/.claude/CLAUDE.md` przestają mówić o "dwóch różnych
aplikacjach". **Dyktowanie**: rekomendujemy równorzędnie Wispr Flow albo
mikrofon pod polem czatu w Claude; dyktowanie systemowe zostaje ostatecznością.

## Otwarte - do decyzji, nie naprawiane

- **Dwie osoby w jednym repo uczestnika.** 54 commity i 3 synchronizacje
  analityki pochodzą z drugiego konta (`j8000`). Wszystkie zdarzenia mają
  `participant_id: P006`, więc dziennika nie da się rozdzielić na osoby.
  Możliwy kierunek: skrót (hash) tożsamości git w `session_start` - bez nazwisk,
  ale z rozróżnieniem maszyn.
- **Tożsamość git ginie przy nowym klonie.** `P006` podpisał tylko commity
  z 09-09; po zmianie nazwy repo (`poc-marcel` → `papla`) i nowych klonach
  commity szły na globalne tożsamości uczestników. U insidera to bez znaczenia,
  u laika oznaczałoby prawdziwe imię w historii. Kierunek: hook startowy
  przywraca lokalne `user.name`/`user.email` = `participant_id`, jeśli ich brak -
  ale tylko w trybie Zero (insider może chcieć własnej tożsamości).
- **Sesje wielodniowe.** Jeden `session_id` obejmuje 09-09 → 09-14. Długość
  sesji przestaje być miarą czasu pracy; analizy czasu trzeba liczyć z odstępów
  między zdarzeniami/commitami.
- **Luka w utopia_ui**: `UtopiaConfirmDialog` bez pełnoszerokich akcji i bez
  wariantu outlined - zgłosić upstream, nie w tym repo.
