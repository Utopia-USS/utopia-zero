# Privacy / Prywatność

**English below. Polska wersja poniżej.**

This document describes exactly what utopia-zero records, where it goes, and how
to switch it off. It is short on purpose: if something here is longer than the
behaviour it describes, the behaviour is wrong.

---

## English

### The short version

Everything utopia-zero records is written **into your own project repository**, as
plain text files you can read, edit and delete. There is no analytics service, no
telemetry endpoint, and nothing is sent to any third party. If nobody else has
access to your repository, nobody else sees any of it.

### One question decides the rest

Stage 0 asks whether you are a **friend of Utopia**. That answer is stored as
`audience` in `zero/config.json` and it governs everything below.

| | friend of Utopia | everyone else (`public`) |
|---|---|---|
| Event log (`zero/analytics/events.jsonl`) | you are asked; yes or no | you are asked; yes or no |
| Conversation transcripts | asked **separately**, never bundled into one "yes" | **never collected, never offered** |
| Who can read it | Utopia, because a prepared repo belongs to Utopia | only you |
| Help channel | `[zero]` issues in your repo, answered by Utopia | none; you are self-hosting |

For `public` the transcript rule is enforced in the session-end hook script, not
only by the config flag, so a wrongly set flag cannot leak a conversation.

### What an event actually contains

Steps taken, stage transitions, decisions with their rationale, errors (first line
only), build results and durations, question/answer pairs (the **length** of your
answer, not its text), and satisfaction scores. Keyed by a participant id such as
`P002`. **Never your name, never file contents, never a URL with credentials.**

Secrets are redacted before writing: GitHub tokens, `sk-*` and `AIza*` keys, long
`Bearer` values and e-mail addresses are replaced with `[REDACTED]`.

### Turning it off

Say **"wyłącz analitykę"** / **"disable analytics"** at any moment. The flags flip
in `zero/config.json`, one final consent event is recorded, and logging stops. You
can re-enable it the same way.

### Deleting what was already collected

Ask, and the files are deleted. One honest caveat you should hear before you
believe the word "deleted": **removed files remain in the git history** unless the
history is rewritten. If you want them truly gone, ask for the history rewrite as
well, and it will be done.

### The published preview, if it is enabled

An optional workflow publishes the **built web app** to Cloudflare Pages at a
public address. Only the compiled app goes there, never the source, never
`zero/`, never your analytics. It is off unless someone configures two secrets,
and it announces the address to you when it first runs.

### What Utopia does with a friend's data

It is research on how well this guided flow works: where people get stuck, which
step costs the most rework, what the wizard gets wrong. Findings are published in
this repository (`docs/PILOT1-FINDINGS.md` and successors) with participants
referred to by id and by first name only where they have agreed to it.

---

## Polski

### Krótko

Wszystko, co utopia-zero zapisuje, ląduje **w Twoim własnym repozytorium projektu**,
jako zwykłe pliki tekstowe, które możesz przeczytać, zmienić i skasować. Nie ma
żadnej usługi analitycznej, żadnego serwera telemetrii, nic nie idzie do firm
trzecich. Jeśli nikt poza Tobą nie ma dostępu do repozytorium, nikt tego nie widzi.

### Jedno pytanie decyduje o reszcie

W etapie 0 przewodnik pyta, czy jesteś **przyjacielem Utopii**. Odpowiedź zapisuje
się jako `audience` w `zero/config.json` i rządzi wszystkim poniżej.

| | przyjaciel Utopii | pozostali (`public`) |
|---|---|---|
| Dziennik zdarzeń (`zero/analytics/events.jsonl`) | pytamy; tak albo nie | pytamy; tak albo nie |
| Kopie rozmów | pytamy **osobno**, nigdy jednym „tak" razem z resztą | **nigdy nie zbierane i nigdy nie proponowane** |
| Kto to czyta | Utopia, bo przygotowane repo należy do Utopii | tylko Ty |
| Kanał pomocy | zgłoszenia `[zero]` w Twoim repo, odpowiada Utopia | brak; prowadzisz to samodzielnie |

Przy `public` zakaz kopiowania rozmów jest wymuszony w samym skrypcie hooka, nie
tylko flagą w konfiguracji, więc źle ustawiona flaga nie wypuści rozmowy.

### Co naprawdę jest w zdarzeniu

Wykonane kroki, przejścia między etapami, decyzje wraz z uzasadnieniem, błędy
(tylko pierwsza linia), wyniki i czasy budowania, pary pytanie-odpowiedź
(**długość** Twojej odpowiedzi, nie jej treść) oraz oceny satysfakcji. Kluczem jest
identyfikator uczestnika, np. `P002`. **Nigdy Twoje imię, nigdy zawartość plików,
nigdy adres z poświadczeniami.**

Sekrety są zamazywane przed zapisem: tokeny GitHuba, klucze `sk-*` i `AIza*`, długie
wartości `Bearer` i adresy e-mail zamieniają się w `[REDACTED]`.

### Wyłączenie

Powiedz **„wyłącz analitykę"** w dowolnym momencie. Flagi zmieniają się w
`zero/config.json`, zapisuje się jedno ostatnie zdarzenie o zgodzie i logowanie
się kończy. Tak samo można włączyć z powrotem.

### Kasowanie tego, co już zebrane

Poproś, a pliki znikną. Jedno uczciwe zastrzeżenie, zanim uwierzysz w słowo
„skasowane": **usunięte pliki zostają w historii gita**, dopóki historia nie
zostanie przepisana. Jeśli mają zniknąć naprawdę, poproś też o przepisanie
historii - zostanie zrobione.

### Publiczny podgląd, jeśli jest włączony

Opcjonalny mechanizm publikuje **zbudowaną aplikację** na Cloudflare Pages pod
publicznym adresem. Trafia tam wyłącznie skompilowana aplikacja: nigdy kod
źródłowy, nigdy `zero/`, nigdy analityka. Jest wyłączony, dopóki ktoś nie ustawi
dwóch sekretów, a przy pierwszym uruchomieniu podaje Ci adres.

### Co Utopia robi z danymi przyjaciela

To badanie nad tym, jak dobrze działa ta prowadzona ścieżka: gdzie ludzie się
zacinają, który krok kosztuje najwięcej poprawek, co przewodnik robi źle. Wnioski
publikujemy w tym repozytorium (`docs/PILOT1-FINDINGS.md` i kolejne), a uczestnicy
występują tam pod identyfikatorem, a imieniem tylko za ich zgodą.
