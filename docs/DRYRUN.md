# Dry-run — karta testera (operacjonalizacja DESIGN §15.1)

Cel: przejść ścieżkę uczestnika **1:1 na czystej maszynie** i zebrać tarcia, zanim
zaproszą prawdziwego uczestnika. Testujesz proces, nie produkt — pomysł na apkę ma
być mały (np. lista zakupów).

## Przygotowanie

- Czysta maszyna (bez Fluttera/gita/pluginów), internet, ~10 GB wolnego.
- ZIP `poc-<slug>.zip` przesłany **prywatnym kanałem** (zawiera token).
- Login do Claude (subskrypcja).
- Operator obserwuje z drugiej strony: commity/pushe + `zero/analytics/events.jsonl`
  w repo `poc-<slug>` + issues `[zero]`.

## Zasady grania laika

1. **Nie pomagaj technicznie.** Nie podpowiadaj komend, nie poprawiaj PATH-a, nie
   otwieraj terminala. Mów, czego chcesz — jak klient, nie jak deweloper.
2. **Mów głosem** (dyktowanie systemowe) — długie, chaotyczne wypowiedzi są
   pożądane; testujemy, czy skill je układa.
3. Gdy coś się wysypie — **pozwól mu się ratować samemu** (ma 5 prób + plany B).
   Interweniujesz dopiero, gdy poprosi Cię o coś wprost albo definitywnie utknie.
4. **Notuj każde tarcie**: minuta, co się stało, czego się spodziewałeś/aś.
   Tarcie = wszystko, co zaskoczyło, zmyliło, trwało za długo albo wymagało
   wiedzy, której laik nie ma.

## Sesja 1 — onboarding → ekran powitalny

Idź po [ONBOARDING-PL](ONBOARDING-PL.md) krok po kroku. Punkty obserwacyjne:

- [ ] Instalacja + logowanie Claude Code bez pomocy.
- [ ] Otwarcie folderu → dialog **Trust** → propozycja instalacji dodatków
      (oba marketplace'y + pluginy). Pojawiła się? Zrozumiała? Fallback potrzebny?
- [ ] Restart po instalacji + tryb **AUTO** — czy instrukcja wystarczyła.
- [ ] Prompt startowy → **Etap 0**: tutorial zrozumiały? informacja o analityce
      jasna? doradzenie modelu sensowne? restart „na hooki" przeszedł gładko?
- [ ] **Etap 1**: wywiad — czy BRIEF (odczytany na głos przez skill) wiernie oddaje
      pomysł; czy pytania klikane/otwarte były we właściwych miejscach.
- [ ] **Etap 2**: instalacje z uczciwymi szacunkami czasu; codegen; **ekran
      powitalny w przeglądarce** zgodny z briefem designowym; push (operator:
      potwierdź commit + `events.jsonl` po sesji).

## Sesja 2 — odporność

- [ ] „kontynuuj" po restarcie aplikacji → stan wraca (STATE wstrzyknięty hookiem).
- [ ] **Celowa awaria**: zepsuj coś ręcznie (np. edytuj plik .dart wprowadzając
      błąd) i poproś o kolejną rzecz → obserwuj drabinkę napraw (max 5) i ton.
- [ ] Eskalacja: doprowadź do utknięcia (albo poproś o coś niemożliwego środowiskowo)
      → issue `[zero]` w repo; operator odpowiada w issue → kolejna sesja podejmuje
      odpowiedź.
- [ ] „wyłącz analitykę" → eventy przestają przyrastać; „włącz analitykę" z powrotem.
- [ ] (Opcjonalnie) podgląd na telefonie przez LAN (`--web-hostname 0.0.0.0`).

## Kryteria zaliczenia

1. Ekran powitalny osiągnięty bez żadnej technicznej pomocy operatora.
2. `events.jsonl` przyrasta po każdej sesji (auto-push), transkrypt ląduje
   w `zero/analytics/transcripts/` (zredagowany).
3. Eskalacja + podjęcie odpowiedzi działają w obie strony.
4. Resume („kontynuuj") działa po pełnym zamknięciu aplikacji.

## Po teście

Lista tarć → poprawki w pluginie/starterze/instrukcji → PR → dopiero wtedy pilot
z prawdziwym uczestnikiem. Windows przechodzi ten sam scenariusz na VM/drugim
laptopie (dodatkowo weryfikuje skrypty `.ps1` w praniu).
