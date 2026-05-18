# Cucine in città

Micro-app Flutter standalone che permette di esplorare le cucine disponibili in una città tramite le API pubbliche di BestieBite. Una sola schermata logica con due viste: ricerca città (autocomplete) e griglia cucine.

## Come runnarlo

**Requisiti:** Flutter stable, Dart ≥ 3.x.

```bash
flutter pub get
flutter run
```

**Device target:** sviluppato e testato su simulatore iOS (iPhone 17, iOS 26.4). Funziona anche su Android best-effort, ma non è stato verificato approfonditamente. Niente setup extra: API BestieBite sono pubbliche e senza auth.

**Test unitari:**

```bash
flutter test
```

## Architettura sintetica

- **Feature-first**: tutto in `lib/features/cuisines/`, divisa in `data/` (DTO + repository + eccezioni) e `presentation/` (controller + sealed state + widget). Niente layer "domain" separato — non c'è abbastanza logica di business per giustificarlo.
- **Riverpod 3** per lo state management. Provider sincroni per servizi (`http.Client`, repository) e `Notifier` per state mutabile (ricerca, cucine, città selezionata).
- **Sealed class + pattern matching** per gli stati UI (`SearchState`, `CuisinesState`). Utilizzo di uno `switch` esaustivo, con stati verificati dal compilatore.
- **Una sola schermata logica**, due viste swappate da `HomeScreen` in base a `selectedCityProvider`. Niente router, niente push/pop: lo state decide cosa mostrare.
- **`http.Client` iniettato nel repository**: la sostituzione via `MockClient` di `package:http/testing.dart` rende i test del data layer semplici, senza dipendenze come `mockito`.

## Una cosa di cui sono orgoglioso

Il `SearchController` (`lib/features/cuisines/presentation/controllers/search_controller.dart`) gestisce in ~50 righe **tre meccanismi** che spesso vengono sbagliati in app reali:
- debounce 300ms con `Timer` cancellabile;
- race-guard tramite `_requestId` (un'eventuale risposta lenta di "mi" non sovrascrive quella già arrivata di "milano");
- cleanup deterministico via `ref.onDispose` (timer cancellati quando il provider muore, niente "Bad state: Notifier disposed" e robe simili).

Tutto modellato come transizioni esplicite di una sealed `SearchState`. La UI è uno `switch` con 5 branch, ognuno con il proprio sotto-widget — niente flag booleani sparsi, niente `if (loading && !error && items.isNotEmpty)`.

## Una cosa che farei diversamente con più tempo

**Test sui controller**. Oggi ho coperto il repository (parsing, error handling, request URI) con 5 test unitari, ma `SearchController` e `CuisinesController` non sono testati. Il pattern sarebbe già pronto grazie all'iniezione del repository via Riverpod. Servirebbero ~10 test per coprire: debounce timing (con `fake_async`), race-guard (due fetch concorrenti, la prima lenta), transizioni Idle ↔ Loading ↔ Suggestions/Empty/Error, retry. È il livello dove si annidano i bug più subdoli (concorrenza, timer pendenti) e dove i test rendono di più.

**Immagini cucine vere** e una migliore immagine per la silhouette dell'Italia, con `cached_network_image` + skeleton/placeholder. Le card mostrano cerchi grigi placeholder per concentrare il review sull'architettura e sui flussi di stato.

**TextOverflow.ellipsis** usa "...", nel mockup invece era utilizzato un semplice "." - però in ottica di non perdere tempo su cose inutili in questa fase, ho deciso di lasciar perdere questo dettaglio.