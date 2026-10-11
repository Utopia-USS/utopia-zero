# Zbuduj swoją aplikację - instrukcja startu (utopia-zero)

**Wersja krótka (zwykle wystarczy):** zainstaluj aplikację **Claude**
(https://claude.com/download) i zaloguj się → rozpakuj ZIP od Utopii → w
zakładce **Code** wybierz **Local** → **Select folder** i wskaż rozpakowany
folder → zgadzaj się na wszystko, o co zapyta (zaufanie folderowi, instalacja
dodatków, restart) → **napisz cokolwiek**, np. „start". Od tej chwili przewodnik prowadzi Cię za rękę - łącznie z
instalacją wszystkiego, czego zabraknie.

Poniżej ta sama droga krok po kroku z obrazkami - na wypadek, gdyby coś poszło
inaczej. Zajmie ~20-30 minut. Nie musisz nic umieć.

## Co będzie potrzebne

- Komputer: **Mac** lub **Windows**, z co najmniej **10 GB** wolnego miejsca.
- Stabilny internet (będą się pobierać duże rzeczy).
- Konto Claude z płatnym planem (**Pro** lub **Max**) - Twoje własne albo dane od Utopii.
- **Paczka ZIP od Utopii** (Twój projekt) - dostajesz ją mailem/komunikatorem.
- ~30 minut spokoju na start.

## Jakie programy się zainstalują (i kto to robi)

| Program | Do czego | Kto instaluje |
|---|---|---|
| **Claude** (zakładka Code) | aplikacja, w której rozmawiasz i powstaje Twój projekt | **Ty** - krok 1 poniżej (jedyna ręczna instalacja) |
| **Git** | „sejf" zapisujący każdy krok pracy | **przewodnik**, w trakcie - poprosi tylko o zgodę |
| **Flutter** | silnik, na którym działa Twoja aplikacja | **przewodnik**, w trakcie (duże pobieranie, ~15 min) |
| Wispr Flow (opcjonalnie) | mówisz zamiast pisać - albo mikrofon wbudowany w Claude | Ty - patrz sekcja „Dyktowanie" na dole |

Czyli: ręcznie instalujesz tylko aplikację Claude. Resztą zajmuje się przewodnik -
gdy poprosi o zgodę na instalację, po prostu się zgódź.

> 🔒 Prywatność: projekt zapisuje przebieg pracy (kroki, decyzje, a kopie rozmów
> tylko wtedy, gdy osobno się na to zgodzisz) w Twoim prywatnym repozytorium, żeby Utopia mogła badać, jak działa ten proces.
> W każdej chwili możesz to wyłączyć - wystarczy napisać: **„wyłącz analitykę"**.

## Krok 1 - Zainstaluj aplikację Claude

Wejdź na **https://claude.com/download** i pobierz aplikację dla swojego systemu
(Mac / Windows). Zainstaluj jak każdy inny program. Masz już Claude na
komputerze? Świetnie - to właściwa aplikacja, upewnij się tylko, że jest aktualna.

> Claude Code nie jest już osobną aplikacją: to zakładka **Code** w zwykłej
> aplikacji Claude (obok Chat i Cowork). Wszystko poniżej dzieje się w tej zakładce.

`[SCREENSHOT: strona pobierania z zaznaczonym przyciskiem]`

## Krok 2 - Zaloguj się

Otwórz Claude i zaloguj się na konto Claude (swoje lub przekazane przez Utopię).
Potem kliknij zakładkę **Code** u góry pośrodku. Jeśli poprosi o zmianę planu,
konto potrzebuje płatnego planu (Pro lub Max).

`[SCREENSHOT: ekran logowania]`

## Krok 3 - Rozpakuj paczkę

Rozpakuj otrzymany ZIP np. do `Dokumenty/MojaAplikacja`. W środku jest gotowy
projekt - nic w nim nie zmieniaj ręcznie.

`[SCREENSHOT: rozpakowany folder]`

## Krok 4 - Otwórz projekt

W zakładce **Code** wybierz **Local**, kliknij **Select folder** i wskaż rozpakowany
folder (ten, w którym są `zero` i `README.md`, a nie folder w środku).

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

## Krok 6 - Sprawdź tryb uprawnień

Obok przycisku wysyłania jest wybór trybu uprawnień. Ustaw **Accept edits**
(projekt zwykle ustawia to sam) - dzięki temu Claude nie będzie pytał o zgodę
przy każdej czynności.

`[SCREENSHOT: wybór trybu obok przycisku wysyłania]`

> Poznasz zły tryb po ciągłych pytaniach „Allow?" - wtedy wróć do tego kroku.

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

Otwórz Claude → zakładka **Code** → swój folder (jest na liście z boku) → napisz: **„kontynuuj"**. Przewodnik
pamięta, na czym skończyliście.

## Dyktowanie - mów, nie pisz

Dwie dobre drogi, wybierz dowolną:

- **Mikrofon w Claude** - ikona mikrofonu pod polem czatu. Nic nie instalujesz:
  klikasz, mówisz, klikasz jeszcze raz i tekst ląduje w polu.
- **Wispr Flow: https://wisprflow.ai** (Windows, Mac, iPhone, Android) - osobna
  aplikacja, która wpisuje to, co mówisz, w dowolne pole tekstowe na komputerze.

Naprawdę warto, i to jest chyba najważniejsza rada w całej tej instrukcji.
Przewodnik buduje Twoją aplikację z tego, co mu powiesz - im więcej szczegółów,
tym trafniejszy wynik. A prawda jest taka, że nikomu nie chce się pisać trzech
akapitów o swoim pomyśle. Powiedzieć trzy akapity - owszem, i to bez wysiłku.
Mówiąc, dajesz przewodnikowi kilka razy więcej informacji przy mniejszym
zmęczeniu. Najbardziej czuć to w wywiadzie o pomyśle na początku.

Dyktowanie wbudowane w system (Windows **Win + H**, Mac: Ustawienia → Klawiatura
→ Dyktowanie) to ostateczność - po polsku bywa zawodne, a u pierwszego
uczestnika nie udało się go uruchomić wcale.

## Dobre nawyki

- Podczas dużych pobierań (np. „to potrwa ~20 minut") zostaw komputer włączony
  i nie zamykaj aplikacji.
- Niczego nie da się bezpowrotnie zepsuć - każdy krok jest zapisywany „w sejfie".

## FAQ - gdy coś nie gra

| Objaw | Co zrobić |
|---|---|
| Brak propozycji instalacji dodatków (krok 5) | Zamknij aplikację **całkowicie** (nie tylko okno), otwórz ją ponownie i otwórz ten sam folder - okienko instalacji dodatków powinno się pojawić; zaakceptuj wszystko. Potem napisz cokolwiek - przewodnik dociągnie resztę sam. Okienko się nie pokazuje? Nie szkodzi - napisz cokolwiek, a przewodnik **pobierze się sam** i poprowadzi Cię normalnie. Uwaga: komendy `/plugin ...` **nie działają w aplikacji** - tylko w Claude Code w terminalu (tam: `/plugin marketplace add Utopia-USS/utopia-zero`, potem `/plugin install utopia-zero@utopia-zero`). |
| Ciągłe pytania „Allow…?" | Zły tryb uprawnień → krok 6. |
| Claude odpowiada, ale nie widzi żadnych plików ani projektu | Jesteś w zakładce **Chat** - przełącz na **Code** i otwórz folder (krok 4). |
| Komunikat o limicie użycia | Twój plan ma limity czasowe. Aplikacja pokazuje, kiedy limit się odnowi - wróć wtedy i napisz „kontynuuj". |
| Coś wygląda na zepsute / nie wiesz, co się dzieje | Napisz po prostu: „co się dzieje?" - przewodnik wyjaśni ludzkim językiem. |
| Nic nie pomaga | Odezwij się bezpośrednio do osoby z Utopii, od której masz paczkę (tym samym kanałem). Awaryjnie: **info@utopiasoft.io**. |

Powodzenia! 🚀
