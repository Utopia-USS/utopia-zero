# Dry-run #2 - Zatoczenie (poc-zatoczenie, P000, 2026-08-10 → 2026-08-18)

Raport z drugiego przebiegu utopia-zero: cała ścieżka 0→6 na prawdziwym, dużym
pomyśle autora, tryb Pro, macOS, maszyna operatora, model Opus 5 / wysoki wysiłek
przez cały czas. Zamknięty tagiem `poc-v1`, handover napisany, ankieta końcowa
zebrana.

Poprzednia runda: [DRYRUN-FINDINGS.md](DRYRUN-FINDINGS.md) (Paplanina, poc-dryrun).
Ten dokument liczy się jako **audyt zewnętrzny** przebiegu: wszystkie liczby niżej
są policzone z `zero/analytics/events.jsonl`, historii gita i kodu, a bramki
(`analyze`, `doctor`, testy) zostały uruchomione ponownie 2026-08-18 na tym
repozytorium, nie przepisane z HANDOVER-a.

## 0. Zastrzeżenia metodologiczne (czytaj przed wnioskami)

- **Uczestnik = autor skilla.** P000 to operator eksperymentu. Nie jest to test
  laika i nie mierzy hipotezy głównej (osoba nietechniczna dochodzi do POC bez
  interwencji). Mierzy **górną granicę** tego, co skill potrafi z dobrze
  prowadzonym rozmówcą, i **dyscyplinę samego skilla** przy długim, ambitnym
  projekcie. To drugie okazało się najciekawsze.
- **Tryb Pro, tutorial pominięty.** Cała warstwa Zero (tutorial, ukrywanie
  technikaliów, kalibracja języka z invariantu 13) w tym przebiegu praktycznie
  nie była testowana.
- **Maszyna nie była czysta** (Flutter, git, utopia_cli już były). Etap 2 nie
  przeszedł prawdziwej instalacji od zera.
- **Skill zmieniał się w trakcie przebiegu.** utopia-zero dostał 12 commitów
  między 08-12 i 08-17 (m.in. reguła o braku myślników 08-12 10:22, invariant 13,
  doradztwo modelowe „quality first" 08-17). Część odchyleń niżej to nie
  nieposłuszeństwo, tylko starszy protokół w długo żyjącej sesji.
- **Operator wszedł w repo trzy razy** (3 commity spoza tożsamości `P000`):
  starter, zmiana nazwy projektu, ponowne wendorowanie `utopia_ui` 08-11.
  Żaden nie był ratunkiem technicznym, ale trzeci to realna interwencja:
  design system zmieniał się pod aplikacją w trakcie budowy.

## 1. Wynik w liczbach

| | |
|---|---|
| Kalendarzowo | 2026-08-10 22:14 → 2026-08-18 18:52 (7 dni 20 h; 08-14 i 08-15 puste) |
| Epizody sesji | 64 (40 unikalnych `session_id`, 46 `session_end`) |
| Czas pracy, suma rozpiętości epizodów | **50 h 14** |
| Czas pracy, przerwy przycięte do 30 min | **21 h 09** (przy 15 min: 16 h 40; przy 60 min: 25 h 33) |
| Rozkład per etap (przy 30 min, wg pola `stage`) | 0: 0:05 · 1: 0:55 · 2: 0:49 · 3: 5:25 · 4: 13:52 |
| Commity | 231 (129 roboczych + 102 automatyczne `zero: analytics sync`), 14 merge'y |
| Kod | 192 pliki Dart, 33 585 linii; `lib/` 24 591 linii (w tym 3 593 generowane) |
| Struktura | 21 ekranów / 16 tras / 7 stanów globalnych / 8 serwisów / 16 własnych widgetów; drift schema v8 z testowanymi migracjami od v1 |
| Testy | **794 zielone** (zweryfikowane dziś, 44 s) |
| `flutter analyze` | **czysty** (zweryfikowane dziś: „No issues found") |
| `utopia doctor` | **0 błędów / 0 ostrzeżeń**, 1 info (niezarejestrowany marketplace) |
| Eventy analityczne | 337 w 23 typach |
| Utknięcia / eskalacje | **0** `stuck`, 0 issue `[zero]`, maksimum 3 próby naprawy na problem (limit to 5) |
| Tokeny (zgłoszone) | in 62,2M · cache read 2,68B · out 5,71M |
| Tokeny (po odjęciu podwójnego liczenia, patrz §6.1) | in ~33M · cache read ~1,42B · out ~2,90M |
| Równowartość API | **~975 USD** (nie 1 794 USD, jak policzyłby dziś `/utopia-zero:report`) |

Rozkład dobowy jest wart zapamiętania przy planowaniu pilota: 117 z 337 eventów
padło między 23:00 i 04:00. To był projekt nocny, prowadzony seriami po 4-6 h.

## 2. Werdykt po miarach sukcesu (DESIGN §1)

### Miara 1 - rozwijalność przez profesjonalistów: POZYTYWNY, 18/20

Samoocena wizarda: 19/20. Moja niezależna ocena po rubryce z `handover.md`:

| # | Kryterium | Pkt | Dowód |
|---|---|---|---|
| 1 | `analyze` czysty | 2 | uruchomione dziś, zero uwag |
| 2 | `utopia doctor` | 2 | 0/0, jedno info o marketplace |
| 3 | Screen/State/View | 2 | **zero** `StatefulWidget`, **zero** `setState` w `lib/` |
| 4 | Idiomy utopia_hooks | 2 | 7 stanów globalnych, brak `flutter_bloc` |
| 5 | Higiena repo | 1 | brak `.idea/` (naprawa z dry-runu #1 trzyma), `.pat` nigdy nie commitowany, **brak prawdziwych sekretów w historii** (80 znaczników `[REDACTED]`, zero wzorców tokenów) - ale 21 plików transkryptów siedzi w historii i zostały 3 martwe branche |
| 6 | BRIEF / DECISIONS / HANDOVER | 2 | 159 wpisów w DECISIONS z uzasadnieniem i alternatywami, HANDOVER zgodny z rzeczywistością |
| 7 | Sensowność zależności | **1** | pubspec komentowany lepiej niż w większości produkcyjnych repo (wybór `file_selector` zamiast `file_picker` z powodu kolizji win32 opisany w miejscu), **ale `utopia_ui` to zależność git bez pinu, jadąca za `main`** - rubryka wymaga pinu tam, gdzie krucho, a tu jest najkruszej |
| 8 | Odpala się z czystego klona | 2 | wizard zweryfikował w katalogu tymczasowym; instrukcja zawiera `build_runner`, bez którego nie zadziała |
| 9 | Testy | 2 | patrz zastrzeżenie niżej, ale ~250 realnych przypadków zachowań to dużo powyżej „smoke test" |
| 10 | Uczciwość TODO | 2 | wzorcowa, patrz §3 |

**Zastrzeżenie do liczby 794**: 544 z tych testów generuje `skin_shape_test` +
`skin_contrast_test`, czyli jedno twierdzenie przemnożone przez 30 palet i
kształtów. Ręcznie napisanych przypadków jest ~250 (najwięcej: repozytorium 30,
podpowiedzi linków 24, blokada notatki 20, import 19, mapa 17). To nadal bardzo
dobry wynik, ale nagłówek „794 zielone" mówi o macierzy motywu, nie o pokryciu
zachowań, i tak powinien być czytany przez zespół przejmujący.

### Miara 2 - ukończenie bez interwencji Utopii: POZYTYWNY

Zero eskalacji, zero `stuck`, drabinka naprawcza nigdy nie przekroczyła 3 prób z
dostępnych 5. Trzy razy strategia nr 1 i 2 zawiodły i dopiero trzecia weszła
(gest długiego przytrzymania na mapie, transkrypcja na iOS, testy widgetowe na
drifcie) - to dokładnie ten kształt, dla którego drabinka istnieje.

Uwaga: droga eskalacyjna (issue `[zero]` + podjęcie odpowiedzi przy SessionStart)
**drugi przebieg z rzędu pozostała nieprzetestowana**, bo nic się nie zacięło.
Przed pilotem trzeba ją wywołać sztucznie.

### Miara 3 - satysfakcja: POZYTYWNY w punkcie końcowym, BRAK SZEREGU CZASOWEGO

Ankieta końcowa: kontrola 5/5, jasność 5/5, frustracja 2/5, zgodność z wizją 5/5,
polecenie 5/5, komentarz otwarty: „nic bym nie zmienial".

Ale to jedyny pomiar. Protokół każe robić puls po etapie 2 i **co ~3 funkcje**;
przy 43 zamkniętych funkcjach powinno być ~15 ankiet, są 2 i obie z 08-18.
Pomiar satysfakcji w czasie, czyli to, co miało pokazać, gdzie proces boli,
w tym przebiegu **nie istnieje**. Patrz §5.3.

### Miara 4 - jakość kodu na każdym etapie: POZYTYWNY

Bramki trzymane przez cały przebieg, w kodzie jeden TODO (wyłączony Crashlytics,
świadomie). Trzy literały koloru poza `skin.dart`: dwa to pełna przezroczystość
`0x00000000`, trzeci to czarny gradient-cień pod tekstem na zdjęciu. Zdanie
z HANDOVER-a „to jedyny plik, który trzyma kolor" jest więc lekko przesadzone,
ale nie fałszywe w sensie, o który chodzi (żadnej barwy marki poza systemem).

## 3. Co poszło wyraźnie lepiej niż w dry-runie #1

1. **Uczciwość handoveru jest najmocniejszą rzeczą w całym przebiegu.**
   „**Android nigdy nie został uruchomiony. Ani razu.**", „ścieżka sukcesu Face ID
   nigdy nie była zaobserwowana", „nagrywanie w tle nietestowane na fizycznym
   telefonie", „testy nie dotykają prawdziwych typów pluginu biometrycznego".
   To są dokładnie te trzy rzeczy, na których zespół przejmujący straciłby dzień
   w ciemno. Sprawdziłem wyrywkowo twierdzenia weryfikowalne (bramki, testy,
   czysty klon) - wszystkie się trzymają. Zero ściemy.
2. **Jakość decyzji technicznych i ich zapis.** 159 wpisów, 34 z 48 eventów
   `decision` z uzasadnieniem **i** odrzuconymi alternatywami. Kilka jest
   naprawdę dojrzałych: story picks jako czysta funkcja dnia i id (bez tabeli
   i bez `Random`), „widziane" trzymane jako **dzień** zamiast boola (rail nie
   umiera z wiekiem archiwum), ścieżki plików trzymane relatywnie (iOS zmienia
   katalog kontenera przy każdej instalacji - błąd znaleziony na żywo i naprawiony
   u źródła), blokada notatki jako drzwi a nie szyfrowanie (zapomniane hasło
   zakrywa notatki, nie niszczy ich).
3. **Higiena repo z dry-runu #1 trzyma.** `.idea/` poza HEAD, commity po
   ścieżkach, `.pat` nigdy nie wszedł, redakcja sekretów w transkryptach
   udowodniona (zero wzorców tokenów w historii, 80 znaczników `[REDACTED]`).
4. **Kontrast przestał być oceniany na oko.** Progi 4,5:1 z BRIEF-u są dziś
   **testem** przechodzącym przez wszystkie 30 palet, a nie zdaniem w prozie.
   Kilka wartości akcentu stoi dokładnie tam, gdzie je zatrzymał test. To
   bezpośrednia odpowiedź na punkt 5 z dry-runu #1 i jest lepsza niż zalecana
   „samokontrola przed pokazaniem ekranu".
5. **Strona design systemu jest generowana z kodu** (`tool/design_system_page.dart`),
   a test czerwienieje, gdy rozjedzie się z motywem. Wcześniejsza wersja była
   ręcznie utrzymywanym HTML-em z komentarzem „nie jest źródłem prawdy". To sam
   skill zauważył i naprawił.
6. **Weryfikacja na symulatorze zamiast weryfikacji w przeglądarce.** Od drugiego
   dnia checkpointy to zrzuty z iOS wysyłane jako pliki, plus prawdziwe tapnięcia
   i swipe'y. Dwa realne błędy wyszły **tylko** z telefonu przy zielonych testach
   (puste nagrania 28 bajtów, pager liczący strony przelotowe jako obejrzane).
   Wniosek zapisany w STATE własnymi słowami: „nie ufaj zielonym testom
   w rzeczach, które dotykają sprzętu".
7. **Poprawka jednej kontrolki wszędzie, nie na jednym ekranie.** Trzy razy w
   jedną noc autor odrzucił kontrolkę, a wizard zmienił ją w całej aplikacji
   (chipy tematów wylatują globalnie, jedno pytanie = jedna kontrolka). Wzorzec
   sam się nazwał w STATE i jest kandydatem do `references/` jako zasada.

## 4. Główne odkrycie: skill traci dyscyplinę dokładnie tam, gdzie robi się ciekawie

To najważniejszy wniosek z tego przebiegu i dotyczy **nie kodu, a danych badawczych**.

Do 2026-08-11 21:08 analityka jest wzorowa. Od 21:08 tego samego dnia, czyli od
wejścia w gęstą pętlę etapu 4, wszystkie payloady zaczynają dryfować z pól
katalogowych w prozę:

| Typ eventu | Zgodne ze schematem | Niezgodne | Pierwszy dryf |
|---|---|---|---|
| `feature_done` | 6 | **37** | 08-11 21:14 (`{feature, tests, schema}` zamiast `{name, commits}`) |
| `checkpoint` | 4 | **15** | 08-11 21:14 (`{what, how}` zamiast `{feature, verdict, rework}`) |
| `decision` | 34 | 14 | 08-12 19:38 |
| `error` | 14 | 8 | 08-11 21:47 (`{what, cause, found_by}` zamiast `{category, signature}`) |
| `feature_start` | 2 | 9 | 08-11 21:08 |
| `answer` | 9 | 7 | 08-11 21:08 |
| `build` | 4 | 3 | 08-11 21:14 |
| `scope_request` | 2 | 3 | 08-11 22:32 |
| `fix_attempt` | 24 | 4 | 08-11 21:14 |

Nowe payloady są **lepsze do czytania przez człowieka** i gorsze o wszystko inne.
Konkretne straty:

- **Wskaźnik reworku po checkpointach, czyli flagowa miara „rozjazd wizja↔implementacja",
  jest niepoliczalny.** 15 z 19 checkpointów nie ma pola `verdict`, żaden dryfujący
  nie ma `rework`. To **ten sam sygnał, który zgubił się w dry-runie #1** (punkt 1
  tamtego raportu). Naprawa została wtedy zapisana jako twarda reguła prozą
  w `analytics.md`. Reguła nie wytrzymała ośmiu dni pracy.
- **Czas na funkcję jest niepoliczalny**: 11 `feature_start` na 43 `feature_done`.
- **Liczba commitów na funkcję jest niepoliczalna**: 6 z 43 `feature_done` ma pole
  `commits`.
- **Taksonomia błędów jest połowiczna**: 8 z 22 eventów `error` bez `category`.
- **Kto znalazł błąd**: pole `found_by` pojawia się w 5 eventach i to nie jest
  pole ze schematu. A to jedna z najciekawszych rzeczy w tych danych: cztery
  z pięciu udokumentowanych znalezisk to **autor na prawdziwym urządzeniu lub na
  prawdziwych danych**, nie testy.
- **`question` w etapie 4 praktycznie nie istnieje**: 11 pytań w całym przebiegu,
  z czego 9 z etapu 0-1. Krok 2 pętli („plan → zatwierdzenie", z obowiązkiem
  logowania `question`/`answer`) nie zostawił śladu przy 43 funkcjach. Pytanie
  badawcze „które pytania sprawiały trudność, proporcja klikane vs mówione"
  jest dla rdzenia eksperymentu bez odpowiedzi.
- Doszły dwa typy spoza katalogu (`feature` ×3, `note` ×1). SKILL.md pozwala
  wymyślić typ, ale każe odnotować to w HANDOVER-ze. Nie odnotowano.

**Diagnoza.** Nie jest to lenistwo modelu, tylko przewidywalny efekt: reguła
zapisana prozą w pliku referencyjnym konkuruje o uwagę z tysiącem linii kontekstu
projektu, a przy 43 funkcjach i 231 commitach przegrywa. Payload zaczyna opisywać
**to, co się właśnie stało**, zamiast wypełniać kolumny tabeli. Dokładnie tak
zachowałby się człowiek prowadzący dziennik.

**Wniosek dla wersji v1.1**: schemat musi być egzekwowany przez `log_event`, nie
przez prozę. Patrz §7 P1.

## 5. Pozostałe odchylenia od protokołu

### 5.1 Numer etapu przestał znaczyć cokolwiek po pierwszym dniu

- `stage_start 2` (08-10 23:31) nie ma pary; następny `stage_end` mówi już
  `stage 4`. Etap 3 nigdy nie został formalnie otwarty ani zamknięty.
- Plik `.stage` utknął na `4` od 08-11 do końca. Skutek: 197 eventów, w tym
  **cały etap 6**, ma w polu wspólnym `stage: "4"`. Handover jest zalogowany jako
  `stage_start` z payloadem `{stage: 6}` i wspólnym polem `4`.
- `stage_end 4` wystąpił trzy razy (08-12 11:53, 08-12 19:25, plus zamknięcie
  handoveru), `stage_start 4` też trzy razy. Nie da się z tego odtworzyć granic.
- Rozkład czasu per etap z §1 jest więc **prawdziwy tylko dla etapów 0-3**.
  Wszystko po 08-11 to jedno wielkie „4", w którym siedzą: reszta etapu 3, cały
  etap 4, cały nieistniejący etap 5 i cały etap 6.

### 5.2 MVP zamknięto w dniu 3, a potem pracowano jeszcze 5 dni bez zmiany etapu

MVP zamknięte 08-12. Potem: skórki i cały system wyglądu, ikona ensō, kanji,
import 88 prawdziwych notatek autora, praca z oddechem, blokada notatki hasłem,
Face ID, przebudowa mapy. To około **60% całej pracy** i formalnie nie należy do
żadnego etapu. Protokół ma na to `tryb Polish`, ale nikt go nie włączył, bo
przejście „MVP zamknięte → dalej budujemy" nie ma w stages.md żadnej ceremonii.

### 5.3 Ankiety pulsu nie odbyły się ani razu

Protokół: puls po etapie 2 i co ~3 funkcje. Rzeczywistość: 0 w trakcie, 2 na
końcu. Miara satysfakcji ma jeden punkt pomiarowy zamiast piętnastu, i to
zebrany po sukcesie, więc obciążony w najgorszy możliwy sposób.

### 5.4 Pracownia poszła własną drogą i wygrała, ale protokół tego nie wie

stages.md etap 1 krok 5 obiecuje `zero/design/tokens.css` + 2-3 zaakceptowane
makiety HTML jako **kontrakt wizualny** na całą budowę, a etap 2 krok 4 każe
wygenerować motyw „z zaakceptowanych tokenów Pracowni".

W tym przebiegu katalog `zero/design/` **nie istnieje**. Warsztat wylądował
w `app/web/design/` (sześć zestawów, pokrętła, trzy ekrany na żywo), potem
w `zero/DESIGN-LAB.md`, a ostatecznie w generowanej stronie design systemu i w
`lib/common/constant/skin.dart` (3 rodziny × 4 kształty × papiery × akcenty = 30
mierzonych palet). Autorska paleta „papier + sepia" została zbudowana, pokazana
i **odrzucona**, potem Utopia verbatim, potem Mech, potem Ensō.

Efekt jest lepszy od protokołu. Ale skill mówi dziś nieprawdę o tym, gdzie leży
kontrakt wizualny, a uczestnik idący etapem 2 krok 4 nie znajdzie tokenów.
Do rozstrzygnięcia świadomie, nie milczeniem.

### 5.5 Etap 5 to fikcja na macOS

Cała weryfikacja od dnia 2 dzieje się na symulatorze iOS wewnątrz etapu 4.
Etap 5 nigdy nie został otwarty. Jednocześnie **największe ryzyko produktowe
w handoverze to „Android nigdy nie uruchomiony"**, mimo że APK zbudowano raz
(08-12) i nikt go nie odpalił. Model etapów pozwolił temu przejść, bo urządzenia
są „opcjonalnym etapem na życzenie", a nie bramką.

### 5.6 Agenci równolegli w worktree: zachowanie poza protokołem

Trzy funkcje mają w payloadzie `parallel_agents: 3`, w historii jest 5 gałęzi
`worktree-agent-*` i jedna `claude/…`. Nic w skillu tego nie opisuje, żaden
`decision` tego nie odnotował, a jedyny ślad to merge commity. Skutki:
przyspieszenie (cztery funkcje zamknięte w jednej minucie 08-12 01:59) kupione
za cenę nieporównywalnego czasu per funkcja i sześciu martwych gałęzi, które
zabrały jedyny odjęty punkt rubryki. Do decyzji: błogosławić z obowiązkiem
logowania, albo wyłączyć w przebiegach badawczych.

### 5.7 Reguła „bez myślników" nie doszła do projektu uczestnika

Reguła weszła do skilla 08-12 10:22. W plikach repo poc-zatoczenie zostało **191
myślników**: 134 w `STATE.md`, 40 w `BRIEF.md`, resztę niosą pliki startera.
Blame pokazuje, że linie z myślnikami są z 08-10 (2), 08-11 (64), 08-12 (66) i
08-13 (1), a potem zero - czyli reguła zaczęła działać na nowy tekst, ale nikt
nie zamiótł istniejącego. Dwa osobne wnioski:

- To potwierdzenie punktu 13 z dry-runu #1: **długo żyjąca sesja nie widzi
  poprawek skilla**. Zmiana reguły w trakcie projektu wymaga jawnego zamiatania.
- **Starter sam łamie regułę**: `starter/.gitignore` linia 1 (komentarz
  „# secrets ... never committed" z myślnikiem w środku), a `zero/config.json`
  uczestnika niesie myślnik w
  `utopia_contact`, wpisany ręką operatora w kroku prepare. Tanie do naprawy dziś.

## 6. Błędy infrastruktury eksperymentu

### 6.1 KRYTYCZNY: tokeny są liczone podwójnie przy każdym wznowieniu sesji

`hook_session_end.sh` sumuje **cały plik transkryptu** przy każdym SessionEnd.
Sesja wznawiana N razy emituje N narastających migawek tego samego licznika,
a `/utopia-zero:report` każe je **sumować**. Dowód z danych:

```
session 12d3cc95:  08-13 09:53 out=301k · 08-13 11:22 out=310k
                   08-16 23:35 out=844k · 08-16 23:35 out=850k
session 774c91fd:  08-18 17:25 out=322k · 08-18 17:31 out=347k
```

Pięć sesji ma po 2-4 takie migawki. Skutek dla tego projektu:

| | zgłoszone (suma) | po deduplikacji (max na sesję) |
|---|---|---|
| out | 5,71M | 2,90M |
| cache read | 2,68B | 1,42B |
| równowartość API | 1 793,91 USD | **~975 USD** |

Czyli raport zawyża koszt o **84%**. Naprawa jest dwuczęściowa: w hooku dopisać
do payloadu, że liczba jest kumulatywna dla sesji (albo liczyć delty względem
poprzedniej migawki), a w `report.md` brać per `session_id` ostatnią migawkę,
nie sumę. Do tego czasu każdy dotychczasowy raport tokenowy jest zawyżony.

Dobra wiadomość: 27 z 46 `session_end` bez danych tokenowych to **wyłącznie**
epizody krótsze niż 2 minuty (szum restartów, punkt 9 z dry-runu #1). Żadne
prawdziwe dane nie przepadły.

### 6.2 Transkrypty: „usunięte" nie znaczy usunięte

08-17 autor poprosił o zaprzestanie kopiowania transkryptów i usunięcie
istniejących. Wizard zrobił dokładnie to, zalogował `consent` i zapisał w
HANDOVER-ze, że autor odmówił przepisywania historii. Ale 21 plików transkryptów
**jest w historii gita** i to jest ta połowa punktu z higieny repo. Redakcja
zadziałała (zero wzorców tokenów, 80 znaczników `[REDACTED]`), więc to nie wyciek,
tylko rozbieżność między słowem „usuń" a tym, co git potrafi. Skill powinien
powiedzieć to jednym zdaniem w chwili prośby, zanim użytkownik uzna sprawę za
zamkniętą.

### 6.3 `.stage` nie ma nikogo, kto by go pilnował

Plik jest pisany ręcznie przez skilla przed `stage_start` i nigdy nie
weryfikowany. Raz rozjechany z rzeczywistością został taki na 7 dni. Hook
SessionStart czyta STATE.md i wstrzykuje podsumowanie - może przy okazji
uzgadniać `.stage` z linią „Etap / Stage" ze STATE.

## 7. Lista poprawek - kandydaci na PR

**P1 - bez tego trzeci przebieg da te same dziury w danych**

1. **Egzekwowanie schematu w `log_event`** (`.sh` i `.ps1`): tabela wymaganych
   kluczy per typ eventu w samym skrypcie; brak klucza → event **i tak leci**
   (nigdy nie blokuj pracy), ale z dopisanym `_schema_warning` i wypisanym na
   stderr komunikatem „event `checkpoint` bez `verdict`". Nieznany typ → to samo.
   Proza w `analytics.md` już raz nie wytrzymała, drugi raz też nie wytrzyma.
2. **Puls satysfakcji jako mechanizm, nie zalecenie**: licznik `feature_done` od
   ostatniej ankiety w `zero/analytics/.pulse`; hook SessionStart dopisuje do
   kontekstu „minęło N funkcji od ostatniej ankiety" przy N ≥ 3.
3. **Deduplikacja tokenów** (§6.1): poprawka w `report.md` (last-per-session)
   plus pole `cumulative: true` w payloadzie `session_end`.
4. **Uzgadnianie `.stage`** przez hook SessionStart ze STATE.md; `stage_end`
   odmawia zamknięcia etapu innego niż zapisany.

**P2 - protokół rozjechany z praktyką**

5. **Rozstrzygnąć Pracownię** (§5.4): albo `zero/design/` wraca jako kontrakt,
   albo stages.md opisuje ścieżkę, która faktycznie wygrała (warsztat w
   `app/web/design/`, generowana strona design systemu, kontrast jako test).
   Dziś skill obiecuje pliki, których nie tworzy.
6. **Weryfikacja na urządzeniu jako bramka, nie opcjonalny etap 5**: „każda
   zadeklarowana platforma odpalona co najmniej raz" wchodzi do listy etapu 6.
   Ten przebieg oddaje aplikację z Androidem, którego nikt nigdy nie uruchomił.
7. **Ceremonia „MVP zamknięte"**: jawne przejście w tryb Polish z nowym
   numerowaniem etapów, żeby 60% pracy nie wpadało do worka „4".
8. **Decyzja o agentach równoległych** (§5.6) plus obowiązek `decision{area:
   "parallelism"}` i sprzątanie gałęzi w etapie 6.
9. **Zamiatanie po zmianie reguły domowej** oraz naprawa myślników w
   `starter/.gitignore` i w szablonie `config.json` / instrukcji prepare (§5.7).
10. **Jedno zdanie prawdy o historii gita** przy prośbie o usunięcie danych (§6.2).

**P3 - jakość danych i drobne**

11. `feature_start` obowiązkowy, inaczej `feature_done` dostaje
    `_schema_warning` (czas per funkcja to jedno z pytań badawczych).
12. `found_by` do katalogu eventu `error` (`author|test|simulator|analyzer`).
    Sam skill wymyślił to pole, bo było potrzebne, i to najciekawsza kolumna
    w tych danych.
13. Normalizacja skal ankiet „wyżej = lepiej" (punkt 14 z dry-runu #1, nadal
    nie zrobiony: `frustration: 2` wymaga interpretacji z zewnątrz).
14. Pominąć `session_start`/`session_end` dla epizodów < 10 s (punkt 9 z
    dry-runu #1): 27 z 46 zamknięć sesji to szum.

## 8. Czego nadal nie przetestowano przed pilotem

- **Prawdziwy laik.** Dwa dry-runy, dwa razy programista. Tryb Zero, tutorial,
  ukrywanie technikaliów i invariant 13 nie zostały zmierzone w ogóle.
- **Czysta maszyna.** Etap 2 nigdy nie zainstalował Fluttera od zera w tym
  przebiegu.
- **Windows i skrypty `.ps1`.**
- **Eskalacja przez issue `[zero]` i podjęcie odpowiedzi** - drugi przebieg
  z rzędu bez utknięcia, więc trzeba ją wywołać sztucznie.
- **Limity subskrypcji.** ~975 USD równowartości API i 1,42B tokenów cache read
  na jeden POC to realne ryzyko dla uczestnika na planie Pro. Doradztwo
  „quality first" weszło 08-17, czyli po tym przebiegu, i nie zostało
  przetestowane pod limitem.
- **Etap 5 rung 1** (podgląd przez LAN na telefonie) - niepotrzebny, bo był
  symulator.

## 9. Czego nie ruszać (materiał do case study)

- Uczciwość handoveru z nazwanymi ryzykami zamiast wygładzonego raportu.
- DECISIONS jako log z alternatywami i powodami odrzucenia: 159 wpisów, po
  których zespół przejmujący nie musi pytać autora.
- Kontrast i design system jako **testy**, nie zalecenia.
- Checkpoint jako zrzut z prawdziwego urządzenia wysłany jako plik, nie opis.
- Drabinka naprawcza z prawdziwym poddaniem się strategii (3 przypadki, w których
  dopiero trzecie podejście weszło, i jedno świadome porzucenie live-transkrypcji
  na rzecz natywnego kanału).
- Wzorzec „autor odrzuca kontrolkę → zmieniamy ją wszędzie".
- Wzorzec „nie ufaj zielonym testom tam, gdzie sprzęt": dwa realne błędy wyszły
  tylko z telefonu.
