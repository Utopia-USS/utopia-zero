# Zbuduj swoją aplikację - instrukcja startu (utopia-zero)

**Wersja krótka (zwykle wystarczy):** zainstaluj aplikację **Claude Code**
(https://claude.com/download) i zaloguj się → rozpakuj ZIP od Utopii → otwórz
rozpakowany folder w Claude Code (Open project) → zgadzaj się na wszystko, o co
zapyta (zaufanie folderowi, instalacja dodatków, restart) → **napisz cokolwiek**,
np. „start". Od tej chwili przewodnik prowadzi Cię za rękę - łącznie z
instalacją wszystkiego, czego zabraknie.

Poniżej ta sama droga krok po kroku z obrazkami - na wypadek, gdyby coś poszło
inaczej. Zajmie ~20-30 minut. Nie musisz nic umieć.

## Co będzie potrzebne

- Komputer: **Mac** lub **Windows**, z co najmniej **10 GB** wolnego miejsca.
- Stabilny internet (będą się pobierać duże rzeczy).
- Konto Claude z subskrypcją - Twoje własne albo dane od Utopii.
- **Paczka ZIP od Utopii** (Twój projekt) - dostajesz ją mailem/komunikatorem.
- ~30 minut spokoju na start.

## Jakie programy się zainstalują (i kto to robi)

| Program | Do czego | Kto instaluje |
|---|---|---|
| **Claude Code** | aplikacja, w której rozmawiasz i powstaje Twój projekt | **Ty** - krok 1 poniżej (jedyna ręczna instalacja) |
| **Git** | „sejf" zapisujący każdy krok pracy | **przewodnik**, w trakcie - poprosi tylko o zgodę |
| **Flutter** | silnik, na którym działa Twoja aplikacja | **przewodnik**, w trakcie (duże pobieranie, ~15 min) |
| dyktowanie (opcjonalnie) | mówisz zamiast pisać | Ty - patrz sekcja „Dyktowanie" na dole |

Czyli: ręcznie instalujesz tylko Claude Code. Resztą zajmuje się przewodnik -
gdy poprosi o zgodę na instalację, po prostu się zgódź.

> 🔒 Prywatność: projekt zapisuje przebieg pracy (kroki, decyzje, kopie rozmów) w
> Twoim prywatnym repozytorium, żeby Utopia mogła badać, jak działa ten proces.
> W każdej chwili możesz to wyłączyć - wystarczy napisać: **„wyłącz analitykę"**.

## Krok 1 - Zainstaluj aplikację Claude Code

Wejdź na **https://claude.com/download** i pobierz aplikację **Claude Code** dla
swojego systemu (Mac / Windows). Zainstaluj jak każdy inny program.

`[SCREENSHOT: strona pobierania z zaznaczonym przyciskiem]`

## Krok 2 - Zaloguj się

Otwórz Claude Code i zaloguj się na konto Claude (swoje lub przekazane przez Utopię).

`[SCREENSHOT: ekran logowania]`

## Krok 3 - Rozpakuj paczkę

Rozpakuj otrzymany ZIP np. do `Dokumenty/MojaAplikacja`. W środku jest gotowy
projekt - nic w nim nie zmieniaj ręcznie.

`[SCREENSHOT: rozpakowany folder]`

## Krok 4 - Otwórz projekt

W Claude Code wybierz **Open project** i wskaż rozpakowany folder.

`[SCREENSHOT: okno wyboru folderu]`

## Krok 5 - Zgódź się na dodatki

Po otwarciu folderu aplikacja zaproponuje instalację dodatków (marketplace
„utopia-zero" i „utopia-flutter-skills" oraz kilka pluginów). **Zaakceptuj
wszystkie.** Po instalacji zamknij i otwórz aplikację ponownie, i jeszcze raz
otwórz swój folder.

`[SCREENSHOT: okno z propozycją instalacji]`

> Najpierw może pojawić się pytanie, czy **ufasz temu folderowi** (Trust) -
> potwierdź je; dopiero po nim zobaczysz propozycję dodatków.
> Nie pojawiła się żadna propozycja? Zajrzyj do FAQ na dole.

## Krok 6 - Włącz tryb automatyczny

W oknie rozmowy przełącz tryb uprawnień na **automatyczny (auto-accept)** - dzięki
temu Claude nie będzie pytał o zgodę przy każdej czynności.

`[SCREENSHOT: przełącznik trybu z zaznaczonym AUTO]`

> Poznasz, że tryb jest wyłączony, po ciągłych pytaniach „Allow?" - wtedy wróć do
> tego kroku.

## Krok 7 - Zacznij!

Napisz (albo podyktuj) **cokolwiek** - wystarczy:

```
start
```

Od tej chwili prowadzi Cię przewodnik: przedstawi plan etapów, zada pytania o Twój
pomysł i zajmie się całą techniczną resztą. Prefer English? Just start with:
`Let's start. Guide me from zero to my own app.` - język rozmowy dopasuje się do
Ciebie i można go zmienić w każdej chwili.

## Wracasz po przerwie?

Otwórz Claude Code → otwórz swój folder → napisz: **„kontynuuj"**. Przewodnik
pamięta, na czym skończyliście.

## Dyktowanie - mów, nie pisz

Najlepsze odpowiedzi to swobodne, długie wypowiedzi - przewodnik sam je poukłada.
Masz trzy opcje (od najprostszej):

1. **Mikrofon w Claude Code** - ikona mikrofonu przy polu rozmowy. Uwaga:
   najlepiej rozumie **angielski**; po polsku bywa niedokładny.
2. **Dyktowanie systemowe po polsku** (polecane):
   - **Windows**: naciśnij **Win + H**, wybierz język polski i mów - tekst
     wpisuje się prosto do pola rozmowy.
   - **Mac**: Ustawienia systemowe → Klawiatura → Dyktowanie - włącz;
     uruchamia się klawiszem 🎤 (F5) albo podwójnym Fn (🌐) - dokładny skrót
     widać w tym samym miejscu ustawień.
3. **Aplikacja oparta na Whisper** (dla chętnych - najlepsza polszczyzna,
   działa offline): poproś osobę z Utopii o aktualną rekomendację i pomoc w
   instalacji dla Twojego systemu.

## Dobre nawyki

- Podczas dużych pobierań (np. „to potrwa ~20 minut") zostaw komputer włączony
  i nie zamykaj aplikacji.
- Niczego nie da się bezpowrotnie zepsuć - każdy krok jest zapisywany „w sejfie".

## FAQ - gdy coś nie gra

| Objaw | Co zrobić |
|---|---|
| Brak propozycji instalacji dodatków (krok 5) | Zamknij aplikację **całkowicie** (nie tylko okno), otwórz ją ponownie i otwórz ten sam folder - okienko instalacji dodatków powinno się pojawić; zaakceptuj wszystko. Potem napisz cokolwiek - przewodnik dociągnie resztę sam (a jeśli okienka nie widać, spróbuje doinstalować dodatki po cichu). Uwaga: komendy `/plugin ...` **nie działają w aplikacji** - tylko w Claude Code w terminalu (tam: `/plugin marketplace add Utopia-USS/utopia-zero`, potem `/plugin install utopia-zero@utopia-zero`). |
| Ciągłe pytania „Allow…?" | Tryb automatyczny wyłączony → krok 6. |
| Komunikat o limicie użycia | Twój plan ma limity czasowe. Aplikacja pokazuje, kiedy limit się odnowi - wróć wtedy i napisz „kontynuuj". |
| Coś wygląda na zepsute / nie wiesz, co się dzieje | Napisz po prostu: „co się dzieje?" - przewodnik wyjaśni ludzkim językiem. |
| Nic nie pomaga | Odezwij się bezpośrednio do osoby z Utopii, od której masz paczkę (tym samym kanałem). Awaryjnie: **info@utopiasoft.io**. |

Powodzenia! 🚀
