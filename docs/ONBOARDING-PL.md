# Zbuduj swoją aplikację - instrukcja startu (utopia-zero)

**Wersja krótka (zwykle wystarczy):** zainstaluj aplikację **Claude Code**
(https://claude.com/product/claude-code - uwaga: to INNA aplikacja niż zwykły
"Claude"!) i zaloguj się → rozpakuj ZIP od Utopii → otwórz
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
| Wispr Flow (mocno polecane) | mówisz zamiast pisać | Ty - patrz sekcja „Dyktowanie" na dole |

Czyli: ręcznie instalujesz tylko Claude Code. Resztą zajmuje się przewodnik -
gdy poprosi o zgodę na instalację, po prostu się zgódź.

> 🔒 Prywatność: projekt zapisuje przebieg pracy (kroki, decyzje, kopie rozmów) w
> Twoim prywatnym repozytorium, żeby Utopia mogła badać, jak działa ten proces.
> W każdej chwili możesz to wyłączyć - wystarczy napisać: **„wyłącz analitykę"**.

## Krok 1 - Zainstaluj aplikację Claude Code

Wejdź na **https://claude.com/product/claude-code** i kliknij **Download** dla
swojego systemu (Mac / Windows). Zainstaluj jak każdy inny program.

> ⚠️ **Uwaga: "Claude" i "Claude Code" to DWIE RÓŻNE aplikacje.** Potrzebujesz
> **Claude Code** (do budowania). Jeśli masz już zwykłego "Claude" (czat) -
> to nie ten program; doinstaluj Claude Code z linku powyżej.

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

**Zainstaluj Wispr Flow: https://wisprflow.ai** (Windows, Mac, iPhone, Android).

Naprawdę warto, i to jest chyba najważniejsza rada w całej tej instrukcji.
Przewodnik buduje Twoją aplikację z tego, co mu powiesz - im więcej szczegółów,
tym trafniejszy wynik. A prawda jest taka, że nikomu nie chce się pisać trzech
akapitów o swoim pomyśle. Powiedzieć trzy akapity - owszem, i to bez wysiłku.
Mówiąc, dajesz przewodnikowi kilka razy więcej informacji przy mniejszym
zmęczeniu. Najbardziej czuć to w wywiadzie o pomyśle na początku.

Wbudowane dyktowanie w systemie (Windows **Win + H**, Mac: Ustawienia → Klawiatura
→ Dyktowanie) też istnieje, ale po polsku bywa zawodne - u pierwszego uczestnika
nie udało się go uruchomić wcale. Mikrofon w Claude Code najlepiej radzi sobie
z angielskim. Traktuj je jako plan awaryjny, nie pierwszy wybór.

## Dobre nawyki

- Podczas dużych pobierań (np. „to potrwa ~20 minut") zostaw komputer włączony
  i nie zamykaj aplikacji.
- Niczego nie da się bezpowrotnie zepsuć - każdy krok jest zapisywany „w sejfie".

## FAQ - gdy coś nie gra

| Objaw | Co zrobić |
|---|---|
| Brak propozycji instalacji dodatków (krok 5) | Zamknij aplikację **całkowicie** (nie tylko okno), otwórz ją ponownie i otwórz ten sam folder - okienko instalacji dodatków powinno się pojawić; zaakceptuj wszystko. Potem napisz cokolwiek - przewodnik dociągnie resztę sam. Okienko się nie pokazuje? Nie szkodzi - napisz cokolwiek, a przewodnik **pobierze się sam** i poprowadzi Cię normalnie. Uwaga: komendy `/plugin ...` **nie działają w aplikacji** - tylko w Claude Code w terminalu (tam: `/plugin marketplace add Utopia-USS/utopia-zero`, potem `/plugin install utopia-zero@utopia-zero`). |
| Ciągłe pytania „Allow…?" | Tryb automatyczny wyłączony → krok 6. |
| Komunikat o limicie użycia | Twój plan ma limity czasowe. Aplikacja pokazuje, kiedy limit się odnowi - wróć wtedy i napisz „kontynuuj". |
| Coś wygląda na zepsute / nie wiesz, co się dzieje | Napisz po prostu: „co się dzieje?" - przewodnik wyjaśni ludzkim językiem. |
| Nic nie pomaga | Odezwij się bezpośrednio do osoby z Utopii, od której masz paczkę (tym samym kanałem). Awaryjnie: **info@utopiasoft.io**. |

Powodzenia! 🚀
