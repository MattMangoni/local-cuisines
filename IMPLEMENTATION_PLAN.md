# Cucine in città — Implementation Plan

Micro-app Flutter standalone, una sola schermata logica con due "viste" (ricerca città / griglia cucine), basata sulle API pubbliche di BestieBite.

---

## 1. Stack e scelte tecniche

| Area | Scelta | Motivazione sintetica |
|---|---|---|
| **State management** | **Riverpod 3** (`flutter_riverpod ^3.3.1`) | API moderna, type-safe, niente `BuildContext` per leggere stato, gestione nativa di async via `AsyncNotifier` / `FutureProvider`, ottima per il pattern "input → debounce → request → stato". Più leggero di Bloc per un'app a una schermata, meno magico di GetX. **Nota:** `flutter pub add` ha installato la 3.x — usiamo direttamente `Notifier`/`AsyncNotifier` (no `StateNotifier`, deprecato). |
| **HTTP** | `http` (pacchetto ufficiale Dart) | Sufficiente per 2 GET pubbliche senza auth. Niente interceptors, niente complessità. Iniettato nel repository per renderlo testabile con `MockClient`. |
| **JSON parsing** | Manuale via factory `fromJson` | DTO piccoli (2 risposte). Niente `build_runner` evita rumore e tempi di build. Resta facile aggiungere `json_serializable` in seguito se i DTO crescono. |
| **Network images** | `cached_network_image` | Le `image_emoji` sono PNG remote: caching su disco evita di riscaricare a ogni rebuild del grid e dà placeholder/error builder pronti. |
| **Routing** | Nessun pacchetto, `Navigator` + `setState` di alto livello tramite stato Riverpod | Una sola schermata logica, due viste. Aggiungere `go_router` sarebbe over-engineering. |
| **Debounce** | `Timer` interno al controller dell'autocomplete | Una manciata di righe; evita la dipendenza da `rxdart` solo per un `debounceTime`. |
| **Theming** | `ThemeData` dark custom con `ColorScheme.fromSeed` (seed arancione) + override puntuali | Standard Material 3, niente librerie. |

### Versioni Flutter / Dart
Flutter stable corrente, Dart ≥ 3.x (per **sealed classes** e **pattern matching** usati negli stati UI).

### Versioni dipendenze installate
- `flutter_riverpod: ^3.3.1`
- `http: ^1.6.0`
- `cached_network_image: ^3.4.1`

---

## 2. Architettura

Struttura feature-first, layer minimi (data + presentation). Niente "domain" separato: l'app non ha logica di business sufficiente a giustificarlo.

```
lib/
├── main.dart                          # bootstrap + ProviderScope
├── app.dart                           # MaterialApp + theme
├── core/
│   ├── theme.dart                     # dark theme + accent arancione
│   └── http_client.dart               # provider del http.Client (testabile)
└── features/cuisines/
    ├── data/
    │   ├── city_suggestion.dart       # DTO autocomplete
    │   ├── cuisine.dart               # DTO cucina
    │   └── bestiebite_repository.dart # 2 metodi: autocomplete / cuisinesByLocation
    └── presentation/
        ├── home_screen.dart           # orchestratore delle due viste
        ├── controllers/
        │   ├── search_controller.dart # AsyncNotifier<SearchState> + debounce
        │   └── cuisines_controller.dart # AsyncNotifier<CuisinesState>
        ├── state/
        │   ├── search_state.dart      # sealed class
        │   └── cuisines_state.dart    # sealed class
        └── widgets/
            ├── search_bar.dart
            ├── suggestions_list.dart
            ├── cuisines_grid.dart
            ├── cuisine_card.dart
            └── status_views.dart      # Empty / Error / Loading riutilizzabili
```

### Modellazione degli stati (sealed classes Dart 3)

```dart
sealed class SearchState {}
class SearchIdle extends SearchState {}
class SearchLoading extends SearchState {}
class SearchSuggestions extends SearchState { final List<CitySuggestion> items; ... }
class SearchEmpty extends SearchState { final String term; }
class SearchError extends SearchState { final Object error; }

sealed class CuisinesState {}
class CuisinesLoading extends CuisinesState {}
class CuisinesLoaded extends CuisinesState { final List<Cuisine> items; }
class CuisinesEmpty extends CuisinesState {}
class CuisinesError extends CuisinesState { final Object error; }
```

**Perché sealed + pattern matching invece di `AsyncValue<T>`:** gli stati richiesti dal brief (Idle, Searching, Suggestions, No results, Error) non sono il classico `loading/data/error` di `AsyncValue` — `SearchEmpty` e `SearchIdle` sono dati "data" semanticamente diversi che richiedono UI diverse. Una sealed class li rende espliciti e il `switch` esaustivo evita stati dimenticati in UI.

---

## 3. Flusso e gestione stati

### 3.1 Autocomplete (vista 1)

```
keystroke → SearchController.onTermChanged(term)
   ├─ term.length < 2 → state = SearchIdle, cancella timer pendente
   └─ term.length ≥ 2 →
        cancella timer precedente
        avvia Timer(300ms) → state = SearchLoading → repo.autocomplete(term)
          ├─ lista vuota → SearchEmpty
          ├─ lista popolata → SearchSuggestions
          └─ throw → SearchError
```

- **Debounce:** 300ms (brief consiglia ≥ 250).
- **Race condition:** ogni request porta con sé il `term` per cui è stata avviata; quando arriva la risposta, se il `term` corrente è cambiato, scartiamo il risultato. Evita che una risposta lenta sovrascriva una più recente.
- **Min length:** 2 caratteri (l'API ritorna `[]` con 0-1 char; risparmiamo la chiamata).

### 3.2 Selezione città → cucine (vista 2)

Tap su un suggerimento:
1. Salva `selectedCity` (per header con nome e descrizione).
2. Naviga alla vista cucine (semplice cambio di stato di alto livello — `HomeScreen` mostra `CuisinesView` invece di `SearchView`).
3. `CuisinesController.load(lat, lng)` → `CuisinesLoading` → GET → `CuisinesLoaded` / `CuisinesEmpty` / `CuisinesError`.

### 3.3 Back

Tap sulla freccia arancione in alto a sinistra → torna alla vista ricerca **resettando lo stato a `SearchIdle`** (campo svuotato, illustrazione Italia visibile). Implementazione: `ref.invalidate(searchControllerProvider)` + `TextEditingController.clear()`.

### 3.4 Retry

`SearchError` e `CuisinesError` espongono un bottone "Riprova" che richiama lo stesso metodo del controller con gli ultimi parametri.

---

## 4. Repository — contratto

```dart
class BestiebiteRepository {
  BestiebiteRepository(this._client);
  final http.Client _client;

  Future<List<CitySuggestion>> autocomplete(String term, {String lang = 'it', int limit = 8});
  Future<List<Cuisine>> cuisinesByLocation(double lat, double lng);
}
```

- **Base URL** costante privata.
- Status non-200 → throw di un'eccezione tipizzata `BestiebiteApiException` con `statusCode` e `message` per logging più chiaro.
- Parsing JSON in factory dedicate (`CitySuggestion.fromJson`, `Cuisine.fromJson`); ignorano campi non usati (slug, adm1-4, ecc.) per essere resilienti a campi aggiunti dall'API.

---

## 5. UI / design (dai mockup)

### Tema globale
- **Background:** nero pieno (`#000000` / molto vicino), niente sfumature.
- **Surface card:** grigio scuro (`#1C1C1E` circa, stile iOS dark elevated).
- **Accent arancione:** ~`#FF6B3D` (icona lente, freccia back, underline header città).
- **Testo:** primario bianco; secondario grigio chiaro (~`#8E8E93`).
- **Tipografia:** font di sistema. Gerarchia osservata: title 32 bold / city name 36 bold / subtitle 16 muted / body 16 / caption 14 muted / card label 14 medium.
- **Radius:** ~16 px sulle card della griglia e sul card delle suggestions; ~28 px (pill) sulla search bar.

### Vista 1 — Search (mockup #1 Idle + mockup #2 Suggestions)
- **Header:** titolo "Cucine in città" centrato, bold, grande, padding superiore generoso (safe area + ~24px).
- **Search bar:** pill arrotondata sotto al titolo, fill grigio scuro semi-trasparente, icona lente arancione a sinistra, placeholder "Cerca una città...". In focus o quando c'è testo: bordo sottile chiaro visibile (vedi mockup #2). Clear button (×) a destra quando il campo non è vuoto.
- **Idle (mockup #1):** sotto la search bar, illustrazione silhouette dell'Italia centrata (asset SVG/PNG grigio scuro) + caption a 2 righe centrata: *"Inizia a cercare una città per scoprire le cucine disponibili"*.
- **Suggestions (mockup #2):** lista raggruppata in un'unica card arrotondata grigio scuro; ogni riga = nome città bold + secondary_text muted + chevron `>` a destra; divider sottile tra le righe; tap su riga → vista cucine.
- **Loading / Empty / Error:** stessi messaggi/centratura dello slot illustrazione (sostituiscono l'Italia + caption nello stesso layout).

### Vista 2 — Cuisines (mockup #3)
- **Back button:** freccia `←` arancione in alto a sinistra, niente AppBar Material di default — usiamo `SafeArea` + `IconButton` custom per matchare il mockup.
- **Header città:** nome città (es. "Milano") large bold, underline arancione corto (~larghezza del testo) subito sotto il nome. Sottotitolo `secondary_text` (es. "Lombardia, Italia") muted sotto.
- **Counter:** label `"{length} cucine disponibili"` muted, sopra la griglia (usa `length` dalla risposta API).
- **Grid:** `GridView.builder` **3 colonne**, `childAspectRatio` ~0.85 (card leggermente più alta che larga), gap ~12 px. Card = surface scura arrotondata, immagine quadrata (cached network) centrata in alto, nome cucina bold in basso.
- **Label nome cucina:** `Text` con `maxLines: 2` e `overflow: TextOverflow.ellipsis`. Comportamento di fatto:
  - parola singola lunga (es. "Giapponese") → 1 riga troncata con ellipsis ("Giappon...");
  - nome composto (es. "Senza glutine") → wrap naturale su 2 righe grazie agli spazi.
  
  Niente logica custom di split: Flutter sceglie già il wrap solo sugli whitespace, quindi `maxLines: 2 + ellipsis` copre entrambi i casi del mockup in modo dichiarativo.
- **Stati Loading/Empty/Error:** sotto l'header, area centrata con messaggio (retry per Error).

### Asset
- Illustrazione Italia in `assets/images/italy.png` — silhouette monocromatica grigia (~`#3A3A3C`) su fondo trasparente. Recupero da fonte pubblica (Wikimedia Commons, public domain) e, se necessario, la converto/coloro a grigio. Dichiarata in `pubspec.yaml` sotto `flutter > assets`.
- Niente font custom.

### Widget riusabili
`status_views.dart` espone `IdleView`, `EmptyView`, `LoadingView`, `ErrorView({onRetry})` — tutti centrati nello stesso slot, così il passaggio tra stati nella vista ricerca è coerente visivamente.

---

## 6. Testing

Un test unitario richiesto — copriamo il pezzo più "puro" e più a rischio regressione:

**`test/bestiebite_repository_test.dart`** — `BestiebiteRepository` con `MockClient` di `http`:
- Test 1: `autocomplete` parsa correttamente la risposta esempio del brief in `List<CitySuggestion>`.
- Test 2: `autocomplete` con `[]` ritorna lista vuota senza errori.
- Test 3: `cuisinesByLocation` parsa `length` + `data` ed estrae i campi UI usati.
- Test 4: status 500 → throw `BestiebiteApiException`.

**Motivazione:** il parser DTO + repository è il punto in cui un cambio di API o un typo nei chiavi JSON rompe l'app silenziosamente. Test su Controller / Widget aggiungerebbero valore ma il brief li esclude esplicitamente.

---

## 7. Piano di esecuzione (step ordinati)

1. **Pulizia progetto** — rimuovere counter di default da `lib/main.dart`, aggiornare `pubspec.yaml` (nome, descrizione, dipendenze).
2. **Dipendenze** — `flutter_riverpod`, `http`, `cached_network_image` + dev: `mockito` o `http`'s built-in `MockClient` (preferito: zero codegen).
3. **Core** — `theme.dart` con dark theme + accent; `http_client.dart` con provider del `http.Client`.
4. **Data layer** — DTO `CitySuggestion`, `Cuisine`, `BestiebiteRepository`, eccezione tipizzata. Provider Riverpod del repository.
5. **Test** — scrivere `bestiebite_repository_test.dart` con `MockClient`. Eseguire `flutter test`.
6. **Stati + controller** — sealed classes, `SearchController` con debounce e race-guard, `CuisinesController`.
7. **UI — vista ricerca** — `SearchBar` + `SuggestionsList` + stati Idle/Loading/Empty/Error.
8. **UI — vista cucine** — header, `CuisinesGrid`, `CuisineCard`, stati Loading/Empty/Error.
9. **Orchestrazione** — `HomeScreen` decide quale vista mostrare in base allo stato "città selezionata".
10. **Polish** — verifica su simulatore iOS: hot reload sui tre stati principali, controllo aderenza al mockup quando disponibile.
11. **Docs minime** — `README.md` con: come buildare/avviare, scelta state mgmt + breve motivazione, piattaforma testata (iOS simulator).

---

## 8. Cosa NON includiamo (per evitare scope creep)

Per chiarezza, fuori scope come da brief:
- Login, persistenza locale (`shared_preferences`/Hive), navigazione multi-schermata con router.
- Mappa, geocoding inverso, uso di lat/lng al di fuori della chiamata API.
- i18n / `flutter_localizations`.
- Widget test / integration test / E2E.
- Animazioni custom oltre quelle di default di Material.
- CI/CD, fastlane, code signing.

---

## 9. Decisioni finali (risposte ai punti aperti)

1. **Asset Italia:** PNG monocromatica grigia, recuperata da Wikimedia Commons (public domain) e processata se serve.
2. **Piattaforme:** iOS = target principale (verifica su simulatore obbligatoria); Android = bonus best-effort, niente garanzie su test approfonditi.
3. **Back:** reset completo a `SearchIdle` (campo svuotato).
4. **Label cucine:** `maxLines: 2` + `TextOverflow.ellipsis`. Parole singole troncano, nomi composti vanno a capo naturalmente sullo spazio.
