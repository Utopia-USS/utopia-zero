# utopia-zero — design doc

> Wersja 1.1 · 2026-07-31 · autorzy: Claude + Paweł (wywiad → akceptacja)
> Status: **zaakceptowany** — wszystkie decyzje domyślne przyjęte 2026-07-31; architektura repo wg §4/§12.
> Dokument jawny (repo publiczne — zamierzone): nie zawiera sekretów, a transparentność tego,
> co i jak zbieramy, wspiera świadomą zgodę uczestników. Sekrety żyją wyłącznie w prywatnych
> instancjach `poc-*`.

---

## 1. Cel i miary sukcesu

**Hipoteza eksperymentu:** osoba nietechniczna, prowadzona przez jeden skill, jest w stanie samodzielnie
(bez interwencji człowieka z Utopii) doprowadzić własny pomysł do POC/MVP, które zespół profesjonalistów
może następnie przejąć i rozwijać.

Miary sukcesu (w kolejności ważności):

1. **Rozwijalność przez profesjonalistów** — oceniana post-hoc rubryką (§10.6) przez dewelopera Utopii.
2. **Ukończenie POC/MVP bez interwencji Utopii** — liczba i powaga eskalacji (§9).
3. **Satysfakcja uczestnika** — mikro-ankiety w trakcie i na końcu (§10.7).
4. **Jakość kodu** — analyzer clean + `utopia doctor` na każdym etapie.

Produkt uboczny: **case study** procesu — pełna historia decyzji, utknięć i czasu per etap (analityka, §10).

Horyzont czasowy dowolny (godziny–miesiące). Pilot: 1 osoba (dowolna), potem kolejne iteracje.
Wspierane systemy od v1: **macOS i Windows**.

## 2. Uczestnicy i tryby pracy

| Tryb | Kto | Zachowanie skilla |
|---|---|---|
| **Zero (domyślny)** | nie-programista; wiedza o programowaniu z anegdot; umie zainstalować program i zna terminal z widzenia | pełny tutorial, zero żargonu, technikalia ukryte całkowicie (tłumaczone tylko na wyraźne pytanie) |
| **Pro (fast-path)** | programista chcący szybko postawić POC | tutorial pominięty, ton zwięzły, te same etapy i analityka |
| **Polish** | dowolny użytkownik w istniejącym projekcie | skill używany do szlifowania/rozwijania już powstałego POC — bez etapu 0–2 |

Wybór trybu: pierwsze pytanie etapu 0 („Czy programowałeś/aś kiedyś?" — klikane), plus jawne
„jestem programistą, pomiń tutorial" w prompcie działa zawsze.

## 3. Zasady prowadzenia rozmowy (UX)

- **Język**: wykrywany z promptu startowego (PL prompt → PL, EN → EN). Przełączalny w każdej chwili
  bez utraty kontekstu; przełączenie logowane (`language_switch`). Wszystkie dokumenty user-facing
  (BRIEF, STATE, pytania) w języku użytkownika; **kod, commity i HANDOVER.md po angielsku**
  (bo odbiorcą są deweloperzy).
- **Wizard etapowy** z jawnym postępem: każda wypowiedź w nowym etapie zaczyna się od
  „📍 Etap 3/6 — Szkielet aplikacji".
- **Pytania**: proste/rozstrzygające → klikane opcje (AskUserQuestion); wszystko, gdzie liczy się
  bogactwo informacji (pomysł, design, priorytety) → **pytania otwarte**, zachęcające do mówienia
  (uczestnicy używają speech-to-text, długie wypowiedzi są pożądane). Zasada: nigdy nie tracić jakości
  informacji na rzecz klikalności.
- **Granica decyzji**: sfera technologiczna w 100% po stronie skilla (architektura, biblioteki, struktura,
  git, backend-provider); sfera kreatywna w 100% po stronie użytkownika (pomysł, funkcje, wygląd, nazwa,
  priorytety). Skill nigdy nie pyta o technologię; użytkownik może nadpisać każdą decyzję kreatywną.
- **Ton**: technikalia ukryte; komunikaty typu „buduję fundamenty aplikacji", nie „konfiguruję DI".
  Minimum edukacji: tylko pojęcia niezbędne operacyjnie (ok. 5: aplikacja/podgląd, zapis postępu,
  etap, „wysyłam kopię do sejfu" = push, model). Dopytany — tłumaczy chętnie.
- **Checkpointy wizualne opcjonalne**: po etapie 2 skill pyta raz: „Chcesz, żebym po każdej nowej funkcji
  pokazywał Ci działającą aplikację?" (tak / nie / sam sobie odpalam na telefonie). Ustawienie zapisane
  w STATE.md, zmienialne w każdej chwili, logowane.
- **Wielosesyjność (obowiązkowa)**: cały stan w plikach repo (§6.8); powrót = „kontynuuj".

## 4. Architektura rozwiązania

Wszystko, co dotyczy zero, żyje w **jednym publicznym repo `Utopia-USS/utopia-zero`** (to repo):
własny marketplace z pluginem, kopiowany szablon projektu (`starter/`) i dokumentacja.
Pluginy developerskie (hooks, cms, …) pozostają w `utopia-flutter-skills` — utopia-zero je
**konsumuje**, nie duplikuje.

```
┌───────────────────────────────────────────────┐      ┌──────────────────────────────────┐
│ Utopia-USS/utopia-zero (PUBLICZNE, to repo)   │      │ Utopia-USS/utopia-flutter-skills │
│ ├─ .claude-plugin/marketplace.json            │      │ (PUBLICZNE)                      │
│ ├─ plugins/utopia-zero/   ← skill + komendy   │      │ utopia-hooks · utopia-ai-arch ·  │
│ ├─ starter/               ← skorupa projektu  │      │ utopia-dart-lsp · utopia-cms ·   │
│ └─ docs/                  ← DESIGN, onboarding│      │ utopia-reviews                   │
└──────────────┬────────────────────────────────┘      └───────────────┬──────────────────┘
               │ prepare: kopiuje starter/ →                           │
               ▼ nowe prywatne repo                                    │ instalowane
┌───────────────────────────────────────────────┐                      │ automatycznie
│ Utopia-USS/poc-<projekt> (PRYWATNE,           │ ◄────────────────────┘
│ per uczestnik) — kod + stan + analityka       │   (deklaracja obu marketplace'ów
│ + kanał pomocy (issues)                       │    w starter/.claude/settings.json)
└───────────────────────────────────────────────┘
```

- **Plugin `utopia-zero`** (tu, publiczny — każdy może go użyć do skonfigurowania własnego
  prywatnego projektu): cała logika prowadzenia — etapy, playbooki środowiskowe, wywiad,
  analityka semantyczna, zasady handoveru.
- **`starter/`** (podkatalog tego repo — **nie** używamy funkcji „GitHub template", bo ta kopiuje
  całe repo, a repo uczestnika ma być czyste — bez źródeł pluginu i dokumentacji eksperymentu):
  skorupa projektu kopiowana do każdego `poc-<slug>` przez `/utopia-zero:prepare` (v1: ręczny
  checklist, §12). **Aplikacja NIE jest w starterze** — skill generuje ją do `app/` po wywiadzie
  o pomyśle (uniwersalność: to-do, gra, scraper; możliwe komponenty `admin/`, `backend/`).
- **`poc-<projekt>`** (prywatne, per uczestnik, w org Utopia-USS): instancja startera z wypełnionym
  configiem. Jedno repo = kod + stan + analityka + kanał pomocy (issues). Utopia ma podgląd
  na bieżąco przez zwykłe commity/pushe.

### Dostęp uczestnika do repo bez konta GitHub

Uczestnik **nie musi mieć konta GitHub**: przygotowujący tworzy **fine-grained PAT** ograniczony do
tego jednego repo (Contents: rw, Issues: rw, wygasa np. po 90 dniach) i zapisuje go do
**`zero/.pat`** (gitignorowany — trafia tylko do wysyłanej paczki ZIP, nigdy do historii
repo ani do config.json). Skill konfiguruje remote z tym tokenem. Token nigdy nie
przechodzi przez prompt (→ nie trafia do transkryptów), skrypty analityczne redagują wzorce
`github_pat_*`. Publiczne repa (utopia-zero, utopia-flutter-skills) nie wymagają żadnego uwierzytelnienia.
Alternatywa (własne konto GitHub uczestnika) — w przyszłości, gdy proces ma być w pełni samoobsługowy.

**Wymóg organizacyjny (owner org):** w ustawieniach Utopia-USS musi być dozwolony dostęp przez
fine-grained PAT (Org Settings → Third-party Access → Personal access tokens).

## 5. Onboarding uczestnika

Utopia wysyła uczestnikowi **jedną instrukcję** (tekst PL/EN w `docs/`, opcjonalnie wideo nagrane
na jej podstawie) + **paczkę ZIP** (jego repo `poc-<projekt>` z configiem) + tekst promptu:

1. Zainstaluj aplikację Claude Code (link per OS) i zaloguj się (subskrypcja własna lub konto Utopii).
2. Pobierz paczkę ZIP, rozpakuj np. do `Dokumenty/MojaAplikacja`.
3. Otwórz ten folder w Claude Code („Open project") — **aplikacja sama zaproponuje instalację
   marketplace'ów i pluginów** (deklaracje `extraKnownMarketplaces` + `enabledPlugins`
   w `starter/.claude/settings.json`); zaakceptuj.
   *Fallback w instrukcji, gdyby propozycja się nie pojawiła: wklej dwie linijki
   `/plugin marketplace add …` + `/plugin install utopia-zero@utopia-zero`.*
4. Włącz tryb automatyczny (auto-accept) — screenshot w instrukcji. (Starter i tak ustawia
   `permissions.defaultMode: acceptEdits` + szeroki allowlist — pas i szelki.)
5. Wklej **prompt startowy** (po polsku lub angielsku — to ustawia język):
   > „Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji."

Od tego momentu prowadzi skill. Powrót po przerwie = otwórz projekt, napisz „kontynuuj".

## 6. Mapa etapów (wizard 0–6)

### Etap 0 — Start i tutorial (pomijalny)
- Czyta `zero/config.json` (participant_id, projekt, analityka) i `zero/STATE.md`.
- Wykrywa język z promptu; pyta o tryb (Zero/Pro) — klikane.
- **Informacja o analityce** (jasnym językiem): co zbieramy, po co, że można wyłączyć w każdej chwili
  („wyłącz analitykę"); zapisuje `consent`-event. Analityka i archiwizacja transkryptów domyślnie ON.
- Tutorial (tryb Zero): jak działa ta rozmowa, co to etapy, jak wrócić po przerwie, że wszystko jest
  zapisywane i nic nie można bezpowrotnie zepsuć, jak mówić do modelu (speech-to-text friendly).
- **Doradztwo modelowe** (§11): sprawdza/zaleca model i poziom wysiłku, tłumaczy jak przełączyć; loguje.
- Konfiguruje git (lokalne user.name = participant_id), weryfikuje remote+PAT, pierwszy testowy push.

### Etap 1 — Pomysł (wywiad kreatywny)
- Pytania otwarte: co to za aplikacja, dla kogo, jaki problem, jak wygląda „udany dzień" z tą apką.
- Doprecyzowanie funkcji → wspólny podział: **MVP teraz / później / poza zakresem** (klikane per funkcja).
- **Detekcja potencjału na panel admina** (utopia_cms): skill sam wyłapuje sygnały (dane zarządzane
  przez właściciela, treści, moderacja, cennik…) i proponuje ludzkim językiem („przyda Ci się miejsce,
  gdzie jako właściciel zmieniasz X bez dotykania aplikacji?"). Decyzja użytkownika.
- **Wywiad designowy** (dogłębny, otwarty): nastrój, styl, kolory, aplikacje-wzorce, czego nie chce.
  Pełna dowolność; przy „nie wiem / zdecyduj ty" skill projektuje wg dobrych praktyk.
- **Pracownia** (dodane 2026-08-10): pełny zestaw tokenów `utopia_ui` + **2–3 makiety HTML**
  kluczowych ekranów MVP (stylowane CSS custom properties o nazwach 1:1 z tokenami),
  oglądane i iterowane w przeglądarce uczestnika, commitowane do `zero/design/`.
  Zaakceptowane makiety = kontrakt wizualny budowy; rework wyglądu dzieje się na tanim
  HTML-u zamiast na kodzie Fluttera. Budowa (Etapy 2–4) idzie na `utopia_ui`
  (drabinka zależności pub.dev → git → tokenizowany Material) + app-local kit na braki
  pakietu (utopia-ui issue #2).
- Wyjście: **`zero/BRIEF.md`** (język użytkownika) — wizja, persony, lista funkcji MVP, brief designowy,
  nazwa robocza. Użytkownik zatwierdza. To pierwszy artefakt „przejmowalności".

### Etap 2 — Fundamenty (cel: „wow" w pierwszej sesji)
- **Środowisko progresywnie** (§7): instaluje tylko to, co potrzebne do celu bieżącego etapu —
  na start **web-first**: git + Flutter SDK + przeglądarka systemowa (Chrome niewymagany).
  Zero Xcode/Android Studio na tym etapie.
- `dart pub global activate utopia_cli` → `utopia create flutter_app` do `app/` (org wg configu).
- Warstwa `.claude/` projektu już jest ze startera; skill dopisuje do CLAUDE.md konwencje
  wynikające z BRIEF (nazwa, język, ustalenia).
- Pierwszy build: ekran powitalny z nazwą i stylem z briefu, uruchomiony w domyślnej
  przeglądarce (`flutter run -d web-server`).
- Commit + push. Ankieta-puls #1 (2 pytania).

### Etap 3 — Szkielet MVP
- Nawigacja + wszystkie ekrany MVP jako szkielety z danymi na niby; klikalne przejścia.
- Checkpoint wizualny (jeśli włączony): „to mapa Twojej aplikacji — zgadza się?" Feedback → korekty.
- `flutter analyze` + `utopia doctor` czyste; commit + push.

### Etap 4 — Funkcja po funkcji (pętla; rdzeń eksperymentu)
Dla każdej funkcji z BRIEF (kolejność: user, z rekomendacją skilla):
1. Plan 1-akapitowy w języku użytkownika → akceptacja (klik).
2. Implementacja (konwencje utopia_hooks / Screen-State-View; decyzje techniczne w 100% skill).
3. **Backend lazy**: pierwszy raz, gdy funkcja go wymaga — skill wybiera providera (Firebase/Supabase),
   a konto: krok **„skontaktuj się z Utopią"** (v1: Utopia udostępnia konto/projekt; kontakt =
   KONKRETNA osoba z `zero/config.json` — członek Utopii, który przygotował projekt, bo uczestnicy
   to znajomi Utopii; skill mówi, co przekazać, czeka na dane, konfiguruje).
   Sekrety → `.env`/gitignore, nie do repo.
4. **Panel admina**: jeśli ustalony w Etapie 1 (lub potrzeba wynikła teraz) — `utopia_cms` w `admin/`.
5. Weryfikacja: analyzer + doctor + build; opcjonalny checkpoint wizualny; wpis do `zero/DECISIONS.md`.
6. Commit + push + eventy. Co ~3 funkcje: ankieta-puls.

### Etap 5 — Urządzenia (opcjonalny, na życzenie)
- Telefon fizyczny / symulator / emulator — dopiero tu ciężkie toolchainy (Xcode, Android Studio).
- macOS: iOS free-provisioning (Apple ID uczestnika, limit 7 dni — uczciwie komunikowany) lub Android.
- Windows: tylko Android + web (brak iOS — komunikowane wprost przy wyborze).
- Każde niepowodzenie ma plan B (§9): telefon → emulator → web. Web zawsze działa.

### Etap 6 — Wykończenie i przekazanie (handover)
- Szlif UI, ikona, nazwa, stany puste/błędów, `flutter analyze`+`doctor` finalnie czyste.
- **`HANDOVER.md`** (EN, dla deweloperów): architektura, mapa modułów, decyzje + odrzucone alternatywy
  (z DECISIONS.md), znane ograniczenia, TODO, jak uruchomić od zera, konta/sekrety — kto ma.
- Tag `poc-v1`. Ankieta końcowa (§10.7). Komunikat „co dalej" (Utopia przejmuje / rozwijamy dalej w trybie Polish).

### 6.8 Wielosesyjność — pliki stanu
```
zero/
├─ config.json      # participant_id, projekt, język, analityka on/off, transcript on/off, remote, kontakt Utopii
├─ STATE.md         # bieżący etap, zrobione, następne kroki, otwarte pytania, ustawienia (checkpointy…)
├─ BRIEF.md         # wizja produktu (język użytkownika)
├─ DECISIONS.md     # log decyzji technicznych: co, dlaczego, alternatywy (EN)
└─ HANDOVER.md      # etap 6 (EN)
```
Hook **SessionStart** wstrzykuje skrót STATE.md do kontekstu + sprawdza (PAT-em) odpowiedzi Utopii
w otwartych issues (§9) → „kontynuuj" działa zawsze, także po tygodniach.

## 7. Strategia środowiska (prywatne, nieznane maszyny)

Zasada: **lazy toolchain** — instalujemy wyłącznie to, czego wymaga cel bieżącego etapu.

| Cel | macOS | Windows |
|---|---|---|
| Web (etap 2–4, domyślny) | Xcode CLT (git) + Flutter SDK + przeglądarka systemowa | Git for Windows (winget) + Flutter SDK + przeglądarka systemowa |
| Android (etap 5) | + Android Studio/SDK + licencje | + Android Studio/SDK + licencje |
| iOS (etap 5) | + pełny Xcode (~dziesiątki GB!) + Apple ID | — (niedostępne; komunikat wprost) |

> Podgląd webowy działa przez `flutter run -d web-server` + domyślną przeglądarkę —
> **Chrome nie jest wymagany** (Safari/Edge wystarczą; jedna instalacja mniej).

- Playbooki per OS w `references/environment-{macos,windows}.md`: wykrywanie (co już jest), instalacja,
  PATH, weryfikacja `flutter doctor` **filtrowana do bieżącego celu** (brak Androida nie blokuje weba).
- Przed dużymi pobraniami: sprawdzenie miejsca na dysku + uczciwa informacja o czasie („to potrwa ~20 min,
  możesz zostawić komputer — nie zamykaj aplikacji").
- Wszystko idempotentne: ponowne uruchomienie etapu niczego nie psuje.

## 8. Backend i CMS

- **v1 (pilot)**: konta backendowe dostarcza Utopia — wpisany w skill krok „skontaktuj się z Utopią"
  (kontakt = osoba, która przygotowała projekt, z configu; fallback `info@utopiasoft.io`;
  skill mówi, co przekazać). Skill konfiguruje otrzymane dane, sekrety poza gitem.
- **Później**: pełne prowadzenie użytkownika przez zakładanie własnych kont (Firebase/Supabase)
  krok po kroku — skill mówi co klikać, ale **konta zakłada i loguje się użytkownik osobiście**
  (twarda zasada bezpieczeństwa: skill nie dotyka haseł/płatności — to również ograniczenie modelu, §13).
- Wybór providera: skill, wg potrzeb funkcji (auth/dane/realtime/pliki). Panel admina: `utopia_cms`
  z delegatem pod wybrany backend, jako osobny komponent `admin/`.

## 9. Awarie i eskalacja

Katalog realnych trybów awarii i odpowiedzi skilla:

| Kategoria | Przykłady | Strategia |
|---|---|---|
| Środowisko | brak miejsca na dysku, PATH, antywirus (Win), licencje SDK, wolna sieć | playbook + retry; plan B: cel „lżejszy" (→web) |
| Build/zależności | konflikt wersji pubspec, Gradle/CocoaPods, emulator nie startuje | max **5 prób naprawy z różnymi strategiami**, potem plan B |
| Logika/oczekiwania | „miało być inaczej" — rozjazd wizji i implementacji | checkpoint → nazwanie różnicy → poprawka; rework logowany |
| Backend | złe klucze, quota, reguły dostępu | diagnoza; jeśli wymaga admina → krok „skontaktuj się z Utopią" |
| Sesja/kontekst | długi projekt, zgubione ustalenia | STATE/BRIEF/DECISIONS jako źródło prawdy; hook SessionStart |
| Claude Code | limity subskrypcji (tygodniowe!), przypadkowo wyłączony auto-accept, aktualizacja pluginów (idziemy z latest — świadome ryzyko) | uczciwy komunikat („limit odnowi się w czwartek — wrócimy wtedy"), instrukcja naprawcza |
| Użytkownik | ręczna edycja plików, uśpiony laptop w trakcie builda, porzucenie | git przywraca; STATE pozwala wrócić; abandon widać w analityce |
| Urządzenia | iOS provisioning (7 dni), tryb dewelopera Androida, kable/sterowniki | drabinka planów B: telefon → emulator → web |

**Drabinka planów B**: zawsze istnieje wariant, który działa (web). Skill nigdy nie zostawia
użytkownika w martwym punkcie — najwyżej odkłada „cięższy" cel na później.

**Eskalacja = GitHub issue w repo projektu**: po wyczerpaniu prób skill (a) loguje event
`stuck`, (b) tworzy PAT-em issue z pełnym kontekstem (etap, błąd, próby, środowisko, link do commita),
(c) mówi po ludzku: „Zatrzymałem się na X. Wysłałem raport do Utopii — możemy w tym czasie robić Y,
albo wróć jutro." SessionStart sprawdza odpowiedzi w issues → asynchroniczna pomoc bez podglądu na żywo
i bez dodatkowej infrastruktury.

## 10. Analityka

### 10.1 Pytania badawcze
Czas+tokeny per etap; liczba i przyczyny utknięć; które pytania sprawiały trudność; decyzje
skilla + uzasadnienia (kluczowe dla oceny rozwijalności). Dodatkowo: wskaźnik reworku po
checkpointach (rozjazd wizja↔implementacja); ile decyzji użytkownik nadpisał; proporcja odpowiedzi
klikanych vs mówionych i ich długość; scope-creep (funkcje dodane poza MVP); taksonomia przyczyn
utknięć; wzorce sesji (pora, długość, przerwy); korelacja rubryki rozwijalności z zachowaniami w trakcie.

### 10.2 Zasada architektoniczna
**Wszystko w repo projektu** (`zero/analytics/`), commitowane i pushowane jak kod. Zero dodatkowej
infrastruktury (bez live-dostępu). Analiza post-hoc = klon repo.

### 10.3 Warstwy zbierania
1. **Hooki Claude Code** (deterministyczne, niezależne od „pamięci" modelu):
   SessionStart/SessionEnd → `zero/scripts/hook_session_*` (wariant `.sh` dla macOS
   i `.ps1` dla Windows; Etap 0 dopina właściwy do **commitowanego** `.claude/settings.json`
   i planuje jeden restart aplikacji).
2. **Eventy semantyczne ze skilla** — skill wywołuje `log_event` przy decyzjach, etapach, pytaniach,
   utknięciach (rzeczy, których hooki nie rozumieją).
3. **Tokeny/koszt/model**: SessionEnd parsuje transkrypt sesji (hook dostaje `transcript_path`) →
   sumy tokenów per model, przybliżony koszt (cennik informacyjnie — użytkownik i tak jest na
   subskrypcji), bucketowane per etap po znacznikach czasu.
4. **Transkrypty**: przy zgodzie (domyślnie ON, §6 Etap 0) kopiowane do `zero/analytics/transcripts/`.
5. **Git sam w sobie**: historia commitów per funkcja = darmowa oś czasu.

### 10.4 Schemat eventów (JSONL, `zero/analytics/events.jsonl`)
Pola wspólne: `ts, participant_id, project_id, session_id, stage, type, payload`.
Typy: `session_start/end` (czas, tokeny, model, koszt-szacunek), `stage_start/end`, `tutorial(skipped)`,
`question(mode: options|open, topic)` / `answer(latency, length, changed_prior)`,
`decision(area, choice, rationale, alternatives, user_involved)`, `user_override`,
`build(target, ok, duration, attempt)`, `error(category, signature)`, `fix_attempt(n, strategy, ok)`,
`stuck(attempts, action)`, `checkpoint(verdict, rework)`, `feature_start/done`,
`scope_request(handled: done|declined_logged)` („live request"), `backend_step(delegated)`,
`language_switch`, `consent`, `env(os, flutter, toolchains)`, `survey(scores, free_text)`, `model_info(model, effort)`.

### 10.5 Prywatność i kontrola
- Wyłączenie w każdej chwili: „wyłącz analitykę" → flaga w config, hooki no-op, wpis `consent`.
  Transkrypty można wyłączyć osobno, zostawiając eventy.
- `log_event` redaguje sekrety (wzorce PAT, klucze API, e-maile poza participant_id).
- Dane pod `participant_id` (nadawany przez przygotowującego repo), nie pod nazwiskiem.
- Formalna zgoda uczestnika: dokument poza narzędziem (organizacyjnie po stronie Utopii);
  skill dodatkowo informuje i loguje akceptację na starcie.

### 10.6 Rubryka rozwijalności (ocena post-hoc przez dewelopera Utopii; 0–2 pkt każde, /20)
analyzer clean · `utopia doctor` pass · zgodność Screen/State/View · stan wg utopia_hooks ·
higiena repo (commity, .gitignore, brak sekretów) · kompletność BRIEF/DECISIONS/HANDOVER ·
sensowność zależności · odpala się z czystego klona · smoke-test obecny · jasność TODO/known-issues.

### 10.7 Ankiety satysfakcji
Puls (2 pytania, skala 1–5 klikana) po etapie 2 i co ~3 funkcje; finał (5 pytań + swobodna wypowiedź):
poczucie kontroli · zrozumiałość · frustracja przy utknięciach · zgodność efektu z wizją · polecenie innym.
Wszystko jako eventy `survey`.

## 11. Doradztwo modelowe

Skill w Etapie 0 (i przy okazjach) doradza model + poziom wysiłku, tłumaczy jak przełączyć w aplikacji,
loguje wybór. Heurystyka (utrzymywana w `references/model-advice.md`, aktualizowana wraz z ofertą modeli):
najmocniejszy dostępny model + wysoki wysiłek na etapy 1–4 (projektowanie i budowa — tu powstaje
jakość, od której zależy rozwijalność); szybszy model / niższy wysiłek dozwolony przy szlifie
kosmetycznym i długich seriach drobnych poprawek. Przy limitach subskrypcji: uczciwa informacja
i propozycja przerwy zamiast degradacji jakości na etapach krytycznych.

## 12. Struktura tego repo

```
utopia-zero/
├─ .claude-plugin/marketplace.json      # własny marketplace: 1 plugin (utopia-zero)
├─ plugins/utopia-zero/
│  ├─ .claude-plugin/plugin.json
│  ├─ commands/
│  │  ├─ start.md                       # /utopia-zero:start — wejście w wizard
│  │  └─ prepare.md                     # /utopia-zero:prepare — strona Utopii: repo+PAT+config+ZIP
│  └─ skills/utopia-zero/
│     ├─ SKILL.md                       # rdzeń: tryby, etapy, zasady UX, granica decyzji
│     └─ references/
│        ├─ stages.md                   # szczegóły etapów 0–6
│        ├─ interview-guide.md          # wywiad o pomyśle + detekcja panelu admina
│        ├─ design-interview.md         # wywiad designowy
│        ├─ environment-macos.md        # playbook środowiskowy
│        ├─ environment-windows.md      # playbook środowiskowy
│        ├─ failure-playbooks.md        # katalog awarii + drabinka planów B + eskalacja issue
│        ├─ analytics.md                # schemat eventów, kiedy logować, redakcja sekretów
│        ├─ handover.md                 # szablon HANDOVER.md + rubryka rozwijalności
│        └─ model-advice.md             # heurystyka model/wysiłek
├─ starter/                             # skorupa kopiowana do każdego poc-<slug> (NIE GitHub template)
│  ├─ README.md                         # quickstart uczestnika (PL/EN)
│  ├─ .gitignore                        # incl. .env, sekrety
│  ├─ .claude/
│  │  ├─ settings.json                  # defaultMode: acceptEdits, allowlist,
│  │  │                                 # extraKnownMarketplaces (utopia-zero + utopia-flutter-skills),
│  │  │                                 # enabledPlugins (zero, hooks, ai-arch, dart-lsp, cms, reviews);
│  │  │                                 # hooki analityczne dopina Etap 0 (per OS)
│  │  └─ CLAUDE.md                      # „projekt w trybie utopia-zero" + konwencje
│  ├─ zero/
│  │  ├─ config.json                    # PLACEHOLDERY: participant_id, projekt, remote, flagi, kontakt
│  │  │                                 # (PAT osobno w zero/.pat — gitignorowany, trafia tylko do ZIP-a)
│  │  ├─ scripts/                       # log_event, hook_session_start, hook_session_end (.sh + .ps1)
│  │  ├─ STATE.md  BRIEF.md  DECISIONS.md  HANDOVER.md   # szkielety
│  │  └─ analytics/                     # events.jsonl, transcripts/
│  └─ app/                              # (puste — generowane w Etapie 2; potem ew. admin/, backend/)
├─ docs/
│  ├─ DESIGN.md                         # ten dokument
│  ├─ ONBOARDING-PL.md                  # instrukcja dla uczestnika (podstawa pod wideo)
│  └─ ONBOARDING-EN.md
└─ README.md
```

### Checklist przygotowania repo dla uczestnika (v1 ręcznie ~10 min; docelowo `/utopia-zero:prepare`)
1. Świeży klon / `git pull` tego repo.
2. `gh repo create Utopia-USS/poc-<slug> --private` (np. `poc-gra-imprezowa`).
3. Skopiuj zawartość `starter/` do nowego katalogu, `git init` + commit + push.
4. Fine-grained PAT ograniczony do nowego repo: Contents rw + Issues rw, wygaśnięcie 90 dni.
5. Wypełnij `zero/config.json` (participant_id, nazwa projektu, remote — bez tokenu, flagi,
   kontakt Utopii), commit + push; PAT zapisz do `zero/.pat` (gitignorowany — wchodzi tylko do ZIP-a).
6. Pobierz ZIP repo → wyślij uczestnikowi ZIP + instrukcję onboardingu + prompt startowy.
7. Podgląd postępu: commity/pushe, `zero/analytics/events.jsonl`, issues (eskalacje).

## 13. Granice i bezpieczeństwo

- **Brak ograniczeń pomysłów** — skill nie limituje tego, CO powstaje (zaufanie do uczestników).
  Realizuje też prośby „poza ścieżką", jeśli potrafi; odmawia grzecznie tylko przy niemożliwym
  i zawsze loguje `scope_request` („live request").
- Ograniczenia **operacyjne** pozostają (to także twarde zasady samego modelu, nie tylko skilla):
  skill nie zakłada kont, nie dotyka haseł/płatności, nie publikuje do sklepów — takie kroki
  **deleguje**: instruuje użytkownika lub wskazuje „to zrobi ktoś z Utopii z kontem admina".
- Sekrety: PAT tylko w `zero/.pat` (gitignorowany; nie w promptach ani w configu), klucze API
  w `.env` poza gitem, redakcja w analityce, `.gitignore` w starterze.
- Limity kosztów: brak (subskrypcja użytkownika); skill jedynie uczciwie komunikuje limity planu.

## 14. Status dokumentu

Żyje w `docs/DESIGN.md` publicznego repo `Utopia-USS/utopia-zero` (decyzja 2026-07-31).
Jawność zamierzona: brak sekretów, a otwartość metodologii (co zbieramy i po co) wspiera świadomą
zgodę uczestników. Publiczne artefakty uczestnika (README startera, instrukcja) — dwujęzyczne PL/EN.

## 15. Roadmap i plan testu

- **v1 (pilot, 1 osoba)**: plugin + starter + instrukcja onboardingu; playbooki **macOS i Windows**;
  web-first; backend na kontach Utopii; analityka w repo; eskalacja przez issues; ręczny checklist
  przygotowania repo (§12).
- **v1.1**: `/utopia-zero:prepare` (automatyzacja przygotowania), skrypt do analizy `events.jsonl`.
- **v2**: prowadzenie przez własne konta backendowe uczestnika; dashboard analityczny
  wielu eksperymentów; rozwinięty tryb Polish; **Claude Design (faza 2 warstwy wizualnej)**:
  lustro utopia_ui jako projekt design-system na claude.ai/design (DesignSync — karty HTML
  komponentów i tokenów), push makiet Pracowni do projektu uczestnika jako trwała galeria,
  docelowo pętla zwrotna (edycje w Claude Design → tokeny). Świadomie odłożone (80/20,
  2026-08-10): rdzeń wartości działa na lokalnych makietach w repo, a lustro wymaga
  utrzymania przy żywym pakiecie 0.1.x.

### 15.1 Dry-run przed pilotem (na koncie Claude Pawła, świeże konto użytkownika macOS + VM Windows)

Świeże konto systemowe = czysty HOME (brak Fluttera, konfiguracji gita, pluginów) przy zachowaniu
własnego sprzętu i subskrypcji Claude. Test pokrywa całą ścieżkę uczestnika:

1. Onboarding 1:1 wg instrukcji: ZIP → otwarcie folderu → auto-propozycja marketplace'ów/pluginów → prompt startowy.
2. Etap 0: tutorial, zgoda na analitykę, doradztwo modelowe, zachowanie auto-accept.
3. Etap 2 na czystym środowisku: instalacja Fluttera od zera (PATH, CLT), `utopia create`, uruchomienie w domyślnej przeglądarce, pierwszy push PAT-em do testowego `poc-dryrun`.
4. Analityka end-to-end: eventy w `events.jsonl`, tokeny/model po zamknięciu sesji, archiwizacja transkryptu, działanie „wyłącz analitykę".
5. Ćwiczenie awarii: celowo zepsuty build → drabinka 5 prób → eskalacja jako issue → odpowiedź w issue → podjęcie jej przy kolejnym SessionStart.
6. Wielosesyjność: zamknięcie, ponowne otwarcie, „kontynuuj" → odtworzenie stanu.
7. Windows (VM): powtórka punktów 1–4 (instalatory, PATH i hooki `.ps1` różnią się całkowicie).

Wynik testu = lista tarć → poprawki → dopiero wtedy pilot z prawdziwym uczestnikiem.

## 16. Decyzje domknięte (2026-07-31)

1. ✅ PAT-w-configu zamiast konta GitHub uczestnika.
2. ✅ Transkrypty domyślnie ON z jasną informacją i łatwym opt-outem.
3. ✅ Commity/HANDOVER po angielsku; wszystko user-facing w języku użytkownika.
4. ✅ Eskalacja przez GitHub issues w repo projektu.
5. ✅ Wszystko w jednym repo `utopia-zero` (marketplace + plugin + starter + docs); `starter/` jako
   podkatalog kopiowany przez prepare — bez funkcji „GitHub template" (repo uczestnika ma być czyste).
6. ✅ Limit 5 prób samodzielnej naprawy przed planem B / eskalacją.
7. ✅ macOS i Windows oba w v1; pilot: dowolna osoba.
8. ✅ Kontakt do Utopii: pole w config wskazuje KONKRETNEGO członka Utopii (operatora,
   który przygotował projekt) — uczestnicy to znajomi i piszą bezpośrednio do niego;
   `info@utopiasoft.io` wyłącznie jako fallback. (Zmienione po dry-runie #1 —
   pierwotnie „generyczny, bez konkretnej osoby", a domyślny adres hello@ był błędny.)
9. ✅ Onboarding: auto-propozycja pluginów z ustawień startera jako ścieżka główna, wklejki jako fallback.
10. ✅ Warstwa wizualna (2026-08-10, po dry-runie #1 „apka wygląda paskudnie"): design-before-code
    na tokenach `utopia_ui` — Pracownia z 2–3 makietami HTML w Etapie 1, budowa na `utopia_ui`
    + app-local kit; Claude Design jako świadomie odłożona faza 2 (80/20). Braki pakietu
    delegowane zespołowi: utopia-ui issue #2; repo utopia-ui będzie publiczne; zmiany tam
    wyłącznie przez PR.
