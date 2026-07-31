# Zbuduj swoją aplikację — instrukcja startu (utopia-zero)

Ta instrukcja prowadzi od zera do momentu, w którym rozmawiasz z Claude'em o swojej
aplikacji. Zajmie ~20–30 minut. Nie musisz nic umieć — od chwili wklejenia
pierwszej wiadomości wszystkim zajmuje się przewodnik.

## Co będzie potrzebne

- Komputer: **Mac** lub **Windows**, z co najmniej **10 GB** wolnego miejsca.
- Stabilny internet (będą się pobierać duże rzeczy).
- Konto Claude z subskrypcją — Twoje własne albo dane od Utopii.
- **Paczka ZIP od Utopii** (Twój projekt) — dostajesz ją mailem/komunikatorem.
- ~30 minut spokoju na start.

> 🔒 Prywatność: projekt zapisuje przebieg pracy (kroki, decyzje, kopie rozmów) w
> Twoim prywatnym repozytorium, żeby Utopia mogła badać, jak działa ten proces.
> W każdej chwili możesz to wyłączyć — wystarczy napisać: **„wyłącz analitykę"**.

## Krok 1 — Zainstaluj aplikację Claude Code

Wejdź na **https://claude.com/download** i pobierz aplikację **Claude Code** dla
swojego systemu (Mac / Windows). Zainstaluj jak każdy inny program.

`[SCREENSHOT: strona pobierania z zaznaczonym przyciskiem]`

## Krok 2 — Zaloguj się

Otwórz Claude Code i zaloguj się na konto Claude (swoje lub przekazane przez Utopię).

`[SCREENSHOT: ekran logowania]`

## Krok 3 — Rozpakuj paczkę

Rozpakuj otrzymany ZIP np. do `Dokumenty/MojaAplikacja`. W środku jest gotowy
projekt — nic w nim nie zmieniaj ręcznie.

`[SCREENSHOT: rozpakowany folder]`

## Krok 4 — Otwórz projekt

W Claude Code wybierz **Open project** i wskaż rozpakowany folder.

`[SCREENSHOT: okno wyboru folderu]`

## Krok 5 — Zgódź się na dodatki

Po otwarciu folderu aplikacja zaproponuje instalację dodatków (marketplace
„utopia-zero" i „utopia-flutter-skills" oraz kilka pluginów). **Zaakceptuj
wszystkie.** Po instalacji zamknij i otwórz aplikację ponownie, i jeszcze raz
otwórz swój folder.

`[SCREENSHOT: okno z propozycją instalacji]`

> Nie pojawiła się żadna propozycja? Zajrzyj do FAQ na dole.

## Krok 6 — Włącz tryb automatyczny

W oknie rozmowy przełącz tryb uprawnień na **automatyczny (auto-accept)** — dzięki
temu Claude nie będzie pytał o zgodę przy każdej czynności.

`[SCREENSHOT: przełącznik trybu z zaznaczonym AUTO]`

> Poznasz, że tryb jest wyłączony, po ciągłych pytaniach „Allow?" — wtedy wróć do
> tego kroku.

## Krok 7 — Zacznij!

Wklej (albo podyktuj) do okna rozmowy:

```
Zaczynamy. Poprowadź mnie od zera do mojej własnej aplikacji.
```

Od tej chwili prowadzi Cię przewodnik: przedstawi plan etapów, zada pytania o Twój
pomysł i zajmie się całą techniczną resztą. Prefer English? Just start with:
`Let's start. Guide me from zero to my own app.` — język rozmowy dopasuje się do
Ciebie i można go zmienić w każdej chwili.

## Wracasz po przerwie?

Otwórz Claude Code → otwórz swój folder → napisz: **„kontynuuj"**. Przewodnik
pamięta, na czym skończyliście.

## Dobre nawyki

- **Mów, nie pisz** — włącz dyktowanie w systemie i opowiadaj swobodnie, długie
  wypowiedzi są najlepsze. Przewodnik sam je poukłada.
- Podczas dużych pobierań (np. „to potrwa ~20 minut") zostaw komputer włączony
  i nie zamykaj aplikacji.
- Niczego nie da się bezpowrotnie zepsuć — każdy krok jest zapisywany „w sejfie".

## FAQ — gdy coś nie gra

| Objaw | Co zrobić |
|---|---|
| Brak propozycji instalacji dodatków (krok 5) | Wklej po kolei dwie linijki: `/plugin marketplace add Utopia-USS/utopia-zero`, potem `/plugin install utopia-zero@utopia-zero`. Zamknij i otwórz aplikację. Resztę dodatków przewodnik dociągnie sam. |
| Ciągłe pytania „Allow…?" | Tryb automatyczny wyłączony → krok 6. |
| Komunikat o limicie użycia | Twój plan ma limity czasowe. Aplikacja pokazuje, kiedy limit się odnowi — wróć wtedy i napisz „kontynuuj". |
| Coś wygląda na zepsute / nie wiesz, co się dzieje | Napisz po prostu: „co się dzieje?" — przewodnik wyjaśni ludzkim językiem. |
| Nic nie pomaga | Napisz do Utopii: **hello@utopiasoft.io** (albo na kanał, którym dostałeś/aś paczkę). |

Powodzenia! 🚀
