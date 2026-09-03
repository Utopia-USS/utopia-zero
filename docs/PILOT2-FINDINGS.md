# Pilot #2 - Nihongo Keiko (poc-filip, P002, 2026-08-26 → w toku)

Drugi przebieg z prawdziwym laikiem i pierwszy na macOS (arm64, Apple Silicon).
Tryb Zero (nigdy nie programował/a), audience: friend, Wispr Flow jako dyktowanie,
plan Pro, doradzone Opus 5 High, wizard w trybie plugin-less (klon `c849b33`).
Wolne miejsce na dysku przy starcie: **13 GB** - etap 2 (Command Line Tools ~1-2 GB
plus Flutter SDK) będzie pierwszą prawdziwą instalacją od zera na czystym Macu
w całym programie i może się nie zmieścić. Jeśli zabraknie miejsca, to jest
znalezisko programu, nie awaria uczestnika.

Równolegle biegnie pilotaż #3 (poc-bartek, P003, także macOS) - poprawki z tej
fali wchodzą do obu przebiegów przez sync skryptów (VERSION), zanim którykolwiek
dotrze do etapów 2-4.

**Ten dokument jest przyrostowy** - pilot trwa, obserwacje dopisujemy falami.
Stan na 2026-09-01: etap 3, aplikacja działa i stoi online pod
https://nihongo-keiko.pages.dev, 103 zdarzenia, 25 commitów uczestnika.
Projekt: osobisty, długoterminowy kurs japońskiego, przeniesiony z **działającego
prototypu HTML, który uczestnik zbudował sam przed programem** i podał jako
odpowiedź na pytanie o pomysł. To odróżnia ten przebieg od pilotażu #1: brief był
gotowy i precyzyjny od pierwszej minuty etapu 1.

Pierwsza sesja (26.08, nocna) urwała się w środku pierwszego pytania wywiadu:
uczestnik zszedł w konfigurację dyktowania i poszedł spać, a wywiad ruszył dopiero
dwa dni później. Wznowienie po tej przerwie zadziałało bez pomocy operatora.

## Co zadziałało pierwszy raz w programie

- **Hooki sesyjne działają natywnie.** `session_start` z `source: startup`
  i `resume` potwierdzone bez ręcznej dyspozycji. To zawęża martwy dispatch
  z pilotażu #1 (fala 1 pkt 3, kandydat 4) do samego Windows desktop.
- **Etap 0 bez interwencji**: zgody, dyktowanie, model advice, git identity,
  remote+PAT, hooki - komplet w kwadrans, wszystkie zdarzenia zalogowane.

## Fala 1 - do naprawy w starterze/pluginie

1. **`.session` jest globalne, a sesje się nakładają - etykiety `session_id`
   kłamały.** Restart aplikacji odpalił CZTERY sesje w 34 sekundy (22:57:22 do
   22:57:56); każda nadpisała `zero/analytics/.session`, a `log_event` czyta ten
   plik w momencie zdarzenia. Efekt w danych: sesja `ffcce63f` ma trzy
   `session_end`, jej dwie sąsiadki żadnego; event `session_end` z
   `transcript_copied: true` nosi id `ffcce63f`, a plik transkryptu zapisany
   w tej samej chwili nazywa się `28438256...jsonl`; commit "analytics sync
   (session de8e6fbf)" opakowuje zdarzenie podpisane `ffcce63f`. Nie da się
   sparować transkryptu z sesją ani policzyć czasu jej trwania. → `log_event`
   honoruje teraz `ZERO_SESSION_ID`, a hook końcowy przekazuje nim id sesji ze
   swojego stdin - zdarzenie, transkrypt i commit mówią jednym głosem.
   **[naprawione w tej fali, skrypty v9]**
2. **Epizody krótsze niż 10 s zaśmiecały dane - rekomendacja wisiała od dwóch
   dry-runów.** Punkt 9 dry-runu #1, punkt 14 dry-runu #2, nigdy nie wdrożone;
   u P002 4 z pierwszych 33 zdarzeń (12%) to pary start/end po sekundzie, plus
   trzy commity "analytics sync" w jedną minutę. → `session_start` jest teraz
   ODROCZONY: hook startowy buduje gotową linię zdarzenia (z prawdziwym ts)
   i parkuje ją w `zero/analytics/.pending/<sid>`; pierwsze prawdziwe zdarzenie
   sesji ją dosypuje (`log_event`), sesja żyjąca ponad 10 s dostaje ją przy
   zamknięciu, a niema sesja poniżej 10 s znika bez śladu - bez zdarzeń, bez
   kopii transkryptu, bez commita. Konsekwencja dla analiz: `events.jsonl` jest
   w kolejności dopisywania, nie ts - sortować po `ts`.
   **[naprawione w tej fali, skrypty v9]**
3. **Model mentalny dyktowania to "podłącz integrację".** Pierwszy ruch po
   instalacji Wispr Flow: prośba do przewodnika "połacz z wisper". Przewodnik
   obsłużył to wzorowo (nie ma czego łączyć, działa systemowo, 4 kroki
   konfiguracji, furtka "pisz z klawiatury i idziemy dalej"), ale zeszło na to
   11 minut nocnej sesji i wywiad stanął. → stages.md etap 0 krok 4a: przy
   rekomendacji od razu jedno zdanie, że to aplikacja systemowa pisząca w KAŻDE
   pole tekstowe i nie trzeba niczego łączyć. **[naprawione w tej fali]**

## Obserwacje bez akcji (fala 1)

- **`_schema_warning` zadziałał i został zignorowany.** Pierwsza odpowiedź
  przebiegu (`stage0-mode`) poszła bez wymaganego klucza `mode`; `log_event`
  dopisał ostrzeżenie do payloadu i na stderr, przewodnik zdarzenia nie
  skorygował - choć wszystkie kolejne `answer` mają już komplet kluczy.
  Walidacja techniczna działa, kanał zwrotny do przewodnika nie. Jeśli się
  powtórzy u P003, kandydat na twardą regułę w analytics.md ("po SCHEMA WARNING
  dolog poprawione zdarzenie").
- **Dane sprzed v9 zostają, jakie są.** Nie przepisujemy `events.jsonl`
  w repo uczestników; analizy tego przebiegu muszą do 2026-08-27 parować
  transkrypty po NAZWIE pliku (id ze stdin hooka), nie po `session_id`
  zdarzeń `session_end`.

## Do obserwacji w następnych sesjach

- **Etap 2 przy 13 GB wolnego dysku** - pierwszy prawdziwy test instalacji
  Fluttera na czystym Macu. Monitorować `env.disk_free_gb` i zdarzenia `error`.
- **Czy sync skryptów do v9 dojdzie sam** - wizard plugin-less robi
  `git pull` klona i porównuje VERSION na wejściu sesji; to pierwszy test tej
  ścieżki na macOS. Sha w linii `wizard: plugin-less (cloned ...)` w STATE musi
  się ruszyć.
- **Dryf logowania etapu 4** (pytania bez odpowiedzi, funkcje bez
  `feature_done`, decyzje niezalogowane) - psuł dane w każdym poprzednim
  przebiegu; u P002 pierwszy sygnał (pkt wyżej) pojawił się już w etapie 0.

## Ingerencje operatora w repo pilota (do uwzględnienia w analizie)

- **2026-08-28: `PAGES_PROJECT = nihongo-keiko`** ustawione w `poc-filip` (zmienna
  repo, nie sekret) i ręczne odpalenie workflow `Web preview`. Powód: dać
  uczestnikowi żywy adres podglądu pod nazwą jego aplikacji, a nie pod wewnętrzną
  nazwą repo, zanim nazwa się utrwali (Cloudflare nie umie zmienić nazwy projektu
  Pages, późniejsza zmiana porzuca stary link). Nie dotyka `app/` ani `zero/`,
  więc danych badawczych nie zmienia; commitów uczestnika nie przybywa. Pierwszy
  przebieg (18:47 UTC) był zielony, ale **pominięty na braku sekretów** - dopiero
  po wpisaniu `CLOUDFLARE_API_TOKEN` i `CLOUDFLARE_ACCOUNT_ID` przebieg o 19:03
  zbudował aplikację i wypchnął 39 plików. **Podgląd żyje pod
  https://nihongo-keiko.pages.dev** (zweryfikowane: `main.dart.js` 2,99 MB, nie
  zaślepka Cloudflare), odświeża się przy każdym pushu uczestnika do `app/`.
  Uwaga przy okazji: ścieżka **Workers Builds** w panelu Cloudflare (podpięcie
  repo przez GitHub App, `npx wrangler deploy`) jest ŚLEPA dla tego programu -
  buduje GitHub Actions, a nazwa zajęta przez Workera zablokowałaby projekt Pages
  o tej samej nazwie. Prepare powinien mówić wprost: token i account id, zero
  integracji z repo.
- **2026-08-28: `README.md`, homepage i opis repo** w `poc-filip` (commit
  operatora `e5d62b3`). README ze startera opisywał "Twoją aplikację" i onboarding
  do Claude Code; zastąpiony opisem projektu z żywym linkiem, listą "co działa"
  i "w budowie" wziętą ze STATE, z zachowaną krótką instrukcją powrotu do pracy.
  Homepage ustawione na adres podglądu. Ten sam ruch co w `poc-janek` 24.08, gdzie
  commit operatora w README przeszedł liniowo, bez konfliktu z przewodnikiem.
  Przy okazji **usunięte imię uczestnika z opisu repo** ("utopia-zero POC -
  Projekt ...") - zasada domowa mówi bez imion, a to wpisaliśmy my na etapie
  prepare. Pozostaje jedno wystąpienie w `zero/BRIEF.md` linia 17, napisane przez
  przewodnika; nietknięte, bo to plik prowadzony przez wizarda.

## Fala 1a - drobiazg wychwycony przy okazji

4. **`/utopia-zero:prepare` krok 6 wypadł przy zakładaniu repo P002.** Sekrety
   Cloudflare są w skrypcie przygotowania opisane jako ustawiane od razu ("set
   both secrets now so the very first stage-2 push deploys itself"), ale
   `poc-filip` (przygotowane 26.08) nie ma ani jednego sekretu, podczas gdy
   `poc-janek` ma komplet od 21.08. Efekt jest łagodny, bo workflow wykrywa brak
   sekretów i zostaje zielony, ale uczestnik przechodzi etapy 2-3 bez żywego
   podglądu, a przewodnik musi tłumaczyć w STATE, dlaczego linku nie wolno podać.
   Kandydat na twardą kontrolę w prepare: po kroku 6 sprawdzić `gh secret list`
   i zgłosić brak, zamiast zakładać, że krok się wykonał.

## Fala 2 - dryf logowania zjada rzecz najważniejszą (sesje 29-31.08)

Kontekst: dwie sesje robocze, 8 commitów, aplikacja urosła o wpisywanie odpowiedzi
w powtórkach, słownik offline zbudowany z samego kursu, zapisywane słowa wracające
jako karty, skróty klawiszowe i klikanie w pojedyncze słowa. Analityka 78 → 103
zdarzenia i po raz pierwszy w tym przebiegu widać pracę inżynierską: 5 `error`
i 6 `fix_attempt`, w tym uczciwa seria trzech prób ze skrótami (dwie nieudane).
W STATE przewodnik założył sam z siebie sekcję "PUŁAPKI, W KTÓRE JUŻ WPADŁEM",
z wpisem samokrytycznym o ogłaszaniu zmian, których `dart format` nie przyjął.
Fala 1 dotarła w komplecie: klon podciągnięty do `dffba8d`, skrypty v9, bramki
przebiegnięte na wejściu sesji.

5. **Pytanie o zmianę aplikacji zostało zadane i nigdy nie domknięte.** 29.08 09:43,
   na checkpoincie etapu 3, uczestnik poprosił o INNĄ aplikację. Przewodnik zalogował
   `question{id:"pivot-new-app", topic:"user asks for a different app ... whether
   Nihongo Keiko is parked or dropped"}` i na tym koniec: brak `answer`, brak
   `decision`, ani słowa w STATE ani w DECISIONS, a siedem minut później praca wraca
   do Nihongo Keiko i trwa do 31.08. Nie wiemy, czy się rozmyślił, czy pomysł wisi.
   Pytanie "czy laik zmienia produkt w połowie drogi" dostało jeden nieuzupełniony
   rekord. → analytics.md reguła twarda **1a**: każde `question` dostaje zdarzenie
   domykające, także gdy wątek umiera (`answer` z `note:"abandoned - ..."` albo
   `decision` odwołująca się do id). **[naprawione w tej fali]**
6. **Para `feature_start`/`feature_done` nie została użyta ANI RAZU** przez 103
   zdarzenia, mimo pięciu gotowych, widocznych dla użytkownika funkcji. Powód jest
   strukturalny: katalog i stages.md wiążą tę parę z pętlą etapu 4, a to jest etap 3.
   Skutki dwa: czas na funkcję znów niepoliczalny (trzeci przebieg z rzędu) i licznik
   pulsu, który siedzi na `feature_done`, nie ruszył się z zera, więc pierwsza ankieta
   satysfakcji nadal nie padła. → analytics.md reguła **5a**: para należy do każdej
   funkcji widocznej dla użytkownika, niezależnie od numeru etapu.
   **[naprawione w tej fali]**
7. **STATE zaprzecza sam sobie po zmianie faktu.** Przewodnik dowiedział się, że
   podgląd żyje, dopisał poprawny adres do nagłówka i zostawił w "ZNANE BRAKI"
   punkt 7 w brzmieniu "NIE odpowiada (brak sekretów Cloudflare). NIE dawać
   użytkownikowi tego linku". Jeden plik twierdzi obie rzeczy naraz, a to plik,
   który wstrzykuje się do kontekstu każdej kolejnej sesji. → SKILL.md invariant 6:
   przy zmianie faktu przegrepować STATE i uzgodnić WSZYSTKIE wystąpienia, nie
   pierwsze. **[naprawione w tej fali]**
8. **Uczestnik nie wie, jak publiczny jest link do podglądu, bo nikt mu tego nie
   mówi.** Adres `*.pages.dev` dostaje własny certyfikat (`CN=<projekt>.pages.dev`),
   więc nazwa trafia do jawnych rejestrów Certificate Transparency w chwili
   pierwszego deployu, niezależnie od tego, komu link zostanie wysłany. Do tego
   scaffold nie zawiera `robots.txt`, a każda nieistniejąca ścieżka zwraca 200
   z aplikacją. Nic z tego nie jest wyciekiem (repo prywatne, publikowany jest sam
   `build/web`, aplikacja nie ma kont ani danych), ale laik słyszy "aplikacja jest
   online" jako "widzą ją tylko ci, którym wyślę". → stages.md etap 2 krok 10: jedno
   zdanie prawdy przy podawaniu linku, `robots.txt` dopisywany po scaffoldzie,
   i Cloudflare Access jako oferta dla chcących zamknąć stronę.
   **[naprawione w tej fali]** Dotyczy też pilotażu #1.
9. **Krok 6b prepare przemilczał własną porażkę** (fala 1a): repo P002 pojechało bez
   sekretów, a workflow uprzejmie pomijał się przy każdym pushu, więc nic nie krzyczało
   aż do etapu 3. → prepare krok 6b: `gh secret list` jako weryfikacja obowiązkowa,
   plus ostrzeżenie, że ścieżka Workers Builds w panelu Cloudflare jest ślepa (podpina
   repo przez GitHub App i zajmuje nazwę, której projekt Pages potem nie dostanie),
   plus reguła bez imion rozciągnięta na opis repo i `project_name`.
   **[naprawione w tej fali]**

## Obserwacje bez akcji (fala 2)

- **Drugi projekt dla P002 przygotowany 2026-09-01** (`poc-filip-2`, to samo
  `participant_id`, nowe `project_id`) jako odpowiedź na punkt 5: zamiast pytać
  uczestnika o porzucony wątek, dajemy mu miejsce, w którym może zbudować drugą
  rzecz bez zamykania pierwszej. Nowe pytanie badawcze, jakiego dotąd nie mieliśmy:
  jak wygląda przebieg kogoś, kto zna już etapy 0-3. Analizy muszą od teraz
  rozbijać P002 po `project_id`.
- **Checkpoint etapu 3 formalnie nieodhaczony**, mimo że uczestnik testował
  aplikację i zgłosił trzy braki na jednym posiedzeniu (`checkpoint{feature:
  "review-session", verdict:"change", rework:1}`). Etap stoi na 3 od 28.08.
- **Kanał eskalacji w stronę Utopii nadal nietknięty**: issue o konto dla silnika
  generującego lekcje stoi w planie jako "WCZEŚNIE" od 28.08 i nie powstało.
  Trzeci przebieg z rzędu bez naturalnego wywołania tej ścieżki.
