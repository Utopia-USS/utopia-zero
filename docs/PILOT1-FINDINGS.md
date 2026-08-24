# Pilot #1 - Wślizgnij To! (poc-janek, P001, 2026-08-18 → w toku)

Pierwszy przebieg z PRAWDZIWYM laikiem - to jest test hipotezy głównej (osoba
nietechniczna dochodzi do rozwijalnego POC bez interwencji operatora), którego
dry-runy [#1](DRYRUN-FINDINGS.md) i [#2](ZATOCZENIE-FINDINGS.md) tylko udawały.

Kontekst: tryb Zero (nigdy nie programował), Windows, słaby sprzęt (i5-2400 z 2011,
4 rdzenie, 16 GB RAM), aplikacja desktop bez `claude` CLI → wizard w trybie
plugin-less (klon w `zero/.wizard`), Opus 5 High na planie Pro. Projekt: gra
imprezowa "Wślizgnij To!" (frazy wplatane w rozmowę).

**Ten dokument jest przyrostowy** - pilot trwa, obserwacje dopisujemy falami.
Stan na 2026-08-21: etapy 0-3 zamknięte, etap 4 w toku. 20.08 to pierwszy pełny
dzień pracy (16:22-21:52, 11 commitów): szkielet MVP, evening flow, persystencja
rozgrywki, własne frazy zaczęte. BRIEF i 3 makiety zaakceptowane za pierwszym
podejściem, bramki czyste, 5 testów przechodzi. Pulse #1: kontrola 5/5,
jasność 5/5 (pulse #2 jeszcze nie należny - licznik na 2).

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

## Obserwacje bez akcji (fale 1-2)
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

## Fala 3 - do naprawy w pluginie (etapy 3-4)
7. **Regresja po naszej własnej poprawce z fali 1: `No MaterialLocalizations found`.**
   Instrukcja "wytnij generator lokalizacji" zabiera razem z nim delegaty
   `flutter_localizations`, a każde `TextField` ich wymaga. Analizator tego nie
   widzi - wybucha dopiero na ekranie, na który patrzy użytkownik. Janek naprawił
   osobnym commitem ("provide Polish material localizations"), następny uczestnik
   może mieć mniej szczęścia. → stages.md etap 2: po usunięciu generatora ZOSTAW
   `flutter_localizations` + `localizationsDelegates` + `supportedLocales`.
   **[naprawione w tej fali]**
8. **Podgląd w trybie debug = biała strona.** dwds dopuszcza jedno połączenie
   debugowe; druga (albo nieodświeżona) karta przeglądarki pokazuje pustą stronę,
   którą laik zgłasza jako "nic się nie otworzyło". Kosztowało drabinę napraw. →
   stages.md + oba playbooki środowiskowe: podgląd dla użytkownika ZAWSZE
   `--release`; debug tylko do własnych sprawdzeń w jednej karcie.
   **[naprawione w tej fali]**
9. **Aplikacja webowa nie przeżywała odświeżenia.** Flutter web odtwarza trasę z
   URL bez argumentów, z jakimi została wypchnięta - szary ekran po F5. Janek
   naprawił splash-first + odczytem stanu ze storage. Laik NA PEWNO naciśnie F5. →
   stages.md etap 3: routing odporny na odświeżenie + sprawdzenie każdego ekranu
   przed checkpointem. **[naprawione w tej fali]**
10. **Etap 4 nie loguje `decision`.** 13 decyzji w etapach 0-3, ZERO w etapie 4 -
   a w tym czasie zapadły wybory: `shared_preferences`, splash-first, tryb
   podglądu. Ten sam dryf, co w dry-runie #2, tylko przeniesiony do pętli funkcji.
   → analytics.md: twarda reguła 6 (etap 4 loguje decyzje jak każdy inny).
   **[naprawione w tej fali]**
11. **GAP w utopia_ui nie ma jak dotrzeć do Utopii.** `UtopiaTextField` ignoruje
   zewnętrzne zmiany wartości po mount (pole nie czyści się po submit) -
   zalogowane jako `error{category:"ui-gap"}` i na tym koniec, bo dyscyplina GAP-ów
   każe "zgłosić upstream", a PAT uczestnika sięga wyłącznie jego repo. →
   utopia-ui-build.md: w projekcie zero "zgłoś upstream" = issue
   `[zero] ui-gap: ...` we WŁASNYM repo (kanał, który Utopia już obserwuje).
   **[naprawione w tej fali]** Sam defekt `UtopiaTextField` czeka na przeniesienie
   do backlogu utopia-ui - do zrobienia po stronie Utopii, nie uczestnika.
12. **Klon przewodnika nigdy się nie aktualizuje - poprawki nie docierały.**
   STATE od 4 sesji podaje ten sam sha `eccbaac` (dzień instalacji). Pull klona
   jest opisany w CLAUDE.md startera, ale NIE MA GO w protokole wejścia w sesję w
   SKILL.md - czyli w checkliście, którą przewodnik faktycznie wykonuje. Skutek:
   fala 1 zmergowana 20.08 o 15:13 nie zadziałała w sesji rozpoczętej o 16:22
   (ręczna dyspozycja hooków dalej bez świeżego `session_id`, `source: unknown`).
   To najpoważniejsze znalezisko tej fali: bez tego kanału ŻADNA nasza poprawka nie
   dociera do trwającego pilota. → SKILL.md: krok 5a (pull klona + odświeżenie sha
   w STATE + sygnał, gdy sha nie drgnął). **[naprawione w tej fali]**

## Ingerencje operatora w repo pilota (do uwzględnienia w analizie)

- **2026-08-21: `.github/workflows/deploy-web.yml`** dodany przez operatora do
  `poc-janek` (commit spoza tożsamości P001), żeby apka deployowała się na
  Cloudflare Pages i miała publiczny link podglądu. Nie dotyka `app/` ani `zero/`,
  więc nie zmienia danych badawczych, ale jest kolejnym commitem operatora w repo
  uczestnika, tak jak sync skryptów v2 z 19.08. Analizy liczą commity P001, nie
  wszystkie. **Zweryfikowane po fakcie**: przewodnik nie zgłupiał od nieznanego
  workflow - sam wpisał link podglądu do STATE i korzysta z niego normalnie.
- **2026-08-23: `.claude/CLAUDE.md` + `zero/config.json`** (reguła 1c o odświeżaniu
  klona, kategoria organizacyjna, `utopia_contact` na uchwyt GitHuba bez em-dasha).
  To jedyny kanał, który sięga zamrożonego przewodnika - patrz fala 4, punkt 14.

## Obserwacje bez akcji (fala 3)
- **Laik przeprojektował przepływ aplikacji.** `user_override{ref:"flow"}`: z
  "setup od razu w akcje" na "setup → rozdanie → gra rozpoczęta → hub gracza,
  akcje tylko w turze", plus `scope_request` na trzy nowe ekrany (obsłużony).
  To dokładnie ten sygnał, którego pilot szuka - nietechniczny użytkownik nie
  tylko akceptuje, ale kształtuje strukturę.
- **Rework wreszcie widoczny w danych**: szkielet 2 rundy poprawek (rework 1, 2),
  persystencja 1. Reguła z dry-runu #1 (każda poprawka = checkpoint) działa.
- **Drobny szum w danych**: pytanie `q-stage4-next` zalogowane dwukrotnie, dwa
  pytania bez sparowanej odpowiedzi (`q-persistence-checkpoint`,
  `q-skeleton-checkpoint-2`), dwa commity z powtórzonym komunikatem (drugi to
  fix-up pierwszego). Nic pilnego, ale to ta sama rodzina co reguła 1.
- **`feature_start` bez `feature_done`**: `mvp-skeleton` (zamknięty przez
  `stage_end` etapu 3) i `custom-phrases` (sesja urwana po commicie). Do
  domknięcia w kolejnej sesji uczestnika.

## Fala 4 - konto Firebase poza Utopią i zamrożony przewodnik

13. **Projekt Firebase powstał na prywatnym koncie uczestnika, na 30-dniowym triaLu,
   bez zaproponowania ścieżki Utopii.** Zgłoszone przez Janka, nie wykryte przez nas.
   Reguła "v1 accounts come from Utopia" ISTNIAŁA w jego (zamrożonej) wersji skilla,
   a `utopia_contact` był ustawiony na osobę z imienia i nazwiska. Przewodnik mimo to
   zalogował `backend_step{step:"project creation handed to the user", delegated:true}`
   - czyli zdelegował, tylko nie tej stronie. Pytania o konto nie było w ogóle.
   Cztery przyczyny, wszystkie naprawione w tej fali:
   - reguła kazała **czekać na człowieka** ("wait, then configure"), co stoi w poprzek
     dominującej doktryny skilla "nigdy nie blokuj początkującego" i przegrało z nią
     w starciu → nowa wersja jest nieblokująca (buduj wszystko, co nie potrzebuje
     kluczy, konfigurację wepnij, gdy przyjdzie);
   - `delegated` było **booleanem** i nie mówiło KOMU, więc odchylenie wyglądało
     w danych jak poprawne wykonanie → `delegated_to: utopia|user|none` (skrypty v4);
   - **nic tego nie pilnowało** → bramka: funkcja z backendem nie jest "done", dopóki
     własność konta nie jest zdecydowana i zalogowana jako
     `decision{area:"backend-account"}`;
   - **nigdzie nie było napisane, czym to grozi** → konsekwencja ("późniejsze
     przeniesienie = nowy projekt od zera i skasowanie tego") jest teraz częścią
     pytania zadawanego użytkownikowi.
   Głębsza przyczyna: skill dzielił decyzje na twórcze (użytkownik) i techniczne
   (przewodnik). Własność konta i rozliczenia to **trzecia kategoria, organizacyjna**,
   której ten podział nie nazywał, więc wpadła do worka "techniczne = przewodnik
   decyduje sam". Kategoria jest teraz nazwana w SKILL.md (wstęp + inwariant 3)
   i w CLAUDE.md startera. **[naprawione w tej fali]**
14. **Zamrożony klon nie może nauczyć się odmrażać.** Fala 3 dodała krok 5a (pull
   klona) do SKILL.md, czyli do pliku, który u zamrożonego uczestnika jest właśnie
   nieaktualny. Klon Janka stoi na `eccbaac` z ~18.08: nie ma nawet kroku
   "Scripts sync" (dodanego w #30), więc jego skrypty to nadal v2 przy upstreamie v3,
   a wszystkie 157 zdarzeń ma `session_id: s0`. Jedyny kanał, który realnie sięga
   działającego pilota, to `.claude/CLAUDE.md` w JEGO repo - i tam instrukcja pullu
   była, ale wciśnięta w środek zdania w podpunkcie (b) reguły 1a, czytanej jak
   poradnik instalacyjny na pierwszy raz. → CLAUDE.md startera dostaje regułę **1c**:
   osobną, samodzielną, "przy każdym starcie sesji", z wyjaśnieniem, czemu mieszka
   właśnie tam. **[naprawione w tej fali]**
15. **Em-dash w `utopia_contact`, drugi raz.** `prepare.md` ostrzega przed tym od
   dry-runu #2, a pilot #1 i tak dostał w tym polu długi myślnik. Przy okazji: pole
   powinno nosić **uchwyt GitHuba**, bo eskalacja idzie przez issues `[zero]` w repo
   uczestnika, gdzie adres e-mail jest bezużyteczny. **[naprawione w tej fali]**
