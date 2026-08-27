# Pilot #2 - pomysł jeszcze w wywiadzie (poc-filip, P002, 2026-08-26 → w toku)

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
Stan na 2026-08-27: etap 0 zamknięty w ~15 minut bez żadnej improwizacji
przewodnika (22:41-22:58 UTC), etap 1 otwarty - pytanie o pomysł (`s1-idea`)
zadane, odpowiedzi brak. Pierwsza sesja była nocna (22:40-01:10 czasu lokalnego)
i urwała się w środku pierwszego pytania wywiadu: uczestnik zszedł w konfigurację
dyktowania i poszedł spać. STATE trzyma "W TOKU - zadane pytanie 1", więc
wznowienie będzie pierwszym testem podjęcia wywiadu w środku kroku.

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
