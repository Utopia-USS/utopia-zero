# Audyt gotowości: od pilotażu Utopii do projektu open source

Cel: **każdy może wziąć utopia-zero i zbudować sobie aplikację**, bez kontaktu
z Utopią, bez ZIP-a od operatora i bez oddawania nam swoich danych. Ten dokument
mówi, co już jest gotowe, co blokuje, i w jakiej kolejności to zdejmować.

Stan na 2026-08-26. Uzupełnienie do [PILOT1-FINDINGS.md](PILOT1-FINDINGS.md)
(co się psuje w praniu) - tutaj chodzi o co innego: co się psuje, gdy po drugiej
stronie nie ma nikogo z Utopii.

## Gdzie jesteśmy

Technicznie system jest **już opublikowany**: repo jest publiczne, ma licencję
BSD-2, a instalacja to jedna komenda marketplace'u Claude Code. W SKILL.md działa
ścieżka **Self-serve bootstrap** dla kogoś bez przygotowanego repo. Wąskim gardłem
nie jest publikacja, tylko to, że pół protokołu zakłada operatora po drugiej
stronie, a domyślne teksty o danych są pisane pod uczestnika badania.

## 1. Dane i zgoda

| Temat | Stan |
|---|---|
| Rozdział „przyjaciel Utopii" / obcy | **zrobione** - pytanie w etapie 0 (krok 2b), zapisywane jako `audience` w configu |
| Transkrypty rozmów dla obcych | **zrobione** - nigdy nie zbierane i nigdy nie proponowane; twardy zapór także w skrypcie hooka, nie tylko we fladze |
| Analityka | pytana u wszystkich, w obu wariantach wyłączalna w każdej chwili |
| Imiona i adresy w plikach projektu | **zrobione** - `utopia_contact` to teraz literalnie `"Utopia"`; skill nigdy nie wypowiada nazwiska ani adresu |
| Gdzie leżą dane | w repo użytkownika; przy `audience: public` nikt z Utopii ich nie widzi, dopóki sam nie udostępni repo |

**Zostaje do zrobienia:** krótki `PRIVACY.md` po polsku i angielsku, mówiący
wprost, co zbiera analityka, gdzie to leży, kto ma do tego dostęp w obu wariantach
i jak to usunąć (z uczciwą uwagą o historii gita - patrz `analytics.md`).
Bez tego pliku obcy musi wnioskować o prywatności z kodu skilla.

## 2. Kroki, które zakładają operatora

| Krok | Obcy | Stan |
|---|---|---|
| PAT do repo | nie ma i nie potrzebuje - używa własnego konta GitHub | degraduje się poprawnie (etap 0 krok 7) |
| Konto backendu (Firebase) | jego własne, nie Utopii | **zrobione** w fali 5: `public` dostaje instrukcję klikania u siebie, nie prośbę do Utopii |
| Podgląd web na Cloudflare | brak sekretów → workflow pomija się na zielono | działa; wart opisania w README jako opcja „podepnij swoje konto" |
| Kanał eskalacji (`[zero]` issues) | brak - nikt nie odpowie | **zrobione**: przy `public` skill mówi wprost „prowadzisz to samodzielnie" i nie odsyła do kontaktu, który milczy |
| `utopia_ui` z gita | repo publiczne, pobiera się samo | bez zmian |

**Zostaje do zrobienia:** przejść ścieżkę obcego na czystej maszynie od zera
(bez `config.json`, bez PAT-a, bez niczego) i sprawdzić, czy bootstrap faktycznie
dowozi do etapu 1. Dziś ta ścieżka jest opisana, ale **nigdy nieprzetestowana** -
wszystkie trzy przebiegi miały przygotowane repo.

## 3. Onboarding

README zaczyna się od „powinieneś dostać ZIP" - czyli od ścieżki, której obcy nie
ma. Kolejność musi się odwrócić: najpierw self-serve (zainstaluj plugin, otwórz
pusty folder, napisz cokolwiek), a program pilotażowy jako sekcja poniżej.
`ONBOARDING-PL/EN` są dobre, ale też pisane pod ZIP.

## 4. Kanał zwrotny

Issues są otwarte, `main` jest chroniony (PR wymagany, bez force-push i kasowania,
zapis tylko dla współpracowników Utopii - obcy forkuje i robi PR). Brakuje:
`CONTRIBUTING.md`, szablonów issue (bug / doświadczenie z przebiegu) i sekcji
„znane ograniczenia" w README. Bez tego pierwszy obcy z popsutymi hookami na
Windowsie po prostu zniknie, zamiast to zgłosić.

## 5. Defekty, które trafią w obcego

- **Hooki nie odpalają się na Windows desktop** (pilot #1, przyczyna nieznana).
  U nas ratuje to ręczna dyspozycja przewodnika, ale obcy nie ma operatora, który
  zauważy, że coś nie działa. **To jest dziś największe ryzyko dla przebiegu bez
  opieki.**
- **`session_id` zostaje `s0`** przy ręcznej dyspozycji - analityka takiego
  przebiegu jest gorszej jakości.
- Dryf logowania w etapie 4 (pytania bez odpowiedzi, funkcje bez `feature_done`) -
  dla obcego bez znaczenia, dla nas psuje dane z każdego przebiegu.

## Rekomendowana kolejność

1. **Dwa, trzy kolejne pilotaże z zaproszenia** (`audience: friend`), koniecznie
   na innym systemie niż Windows i na innym typie pomysłu. Każdy dotychczasowy
   przebieg zwracał klasę błędów, której nikt nie przewidział; przy n=1 nie wiemy,
   co jest regułą, a co cechą jednej maszyny.
2. **Przejście ścieżki obcego na czysto** - jedna sesja, świeży folder, zero
   przygotowania. To jest tania próba, która powie więcej niż godzina czytania
   kodu.
3. **`PRIVACY.md`, `CONTRIBUTING.md`, szablony issue, README odwrócone na
   self-serve.**
4. **Dopiero wtedy głośna publikacja.**

Rzeczy blokującej „technicznie" już nie ma. Blokuje wiedza: nie wiemy jeszcze,
jak ten system zachowuje się bez opiekuna, bo nigdy tak nie działał.
