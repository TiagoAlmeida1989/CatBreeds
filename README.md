# CatBreeds

An iOS app built with SwiftUI that lets you explore cat breeds using [The Cat API](https://thecatapi.com/). Browse the full catalogue, search by name, save favourites, and access all previously loaded content even without an internet connection.

---

## Architecture

The app is built on **The Composable Architecture (TCA)** by Point-Free, which goes beyond the required MVVM pattern and satisfies it as a superset. TCA was chosen for several reasons:

- **Unidirectional data flow** — state can only change through explicit actions, making every transition predictable and traceable.
- **Testability by design** — `TestStore` allows exhaustive assertions on every state mutation and every effect, without mocking at the view layer.
- **Structured concurrency** — effects are modelled as `Effect<Action>` values, making async work cancellable, composable, and easy to test.
- **Dependency injection** — dependencies are declared via `DependencyKey` and injected through the environment, allowing the live, test, and preview values to be swapped with no changes to feature code.

### Layer breakdown

```
┌─────────────────────────────────────┐
│              SwiftUI Views          │  Renders state, sends actions
├─────────────────────────────────────┤
│           TCA Reducers              │  Pure state machines (Features)
├─────────────────────────────────────┤
│        BreedsClient (DI)            │  TCA dependency — entry point for data
├─────────────────────────────────────┤
│         BreedsRepository            │  Orchestrates remote + local sources
├──────────────────┬──────────────────┤
│  Remote (API)    │  Local (SwiftData)│  Independent, protocol-backed
└──────────────────┴──────────────────┘
```

Each layer depends only on the abstraction below it, never on the concrete implementation. This makes every layer independently testable.

---

## Networking

The API layer is built around two protocols:

- **`HTTPClient`** — responsible for executing a `URLRequest` and returning raw `Data`. The concrete implementation, `URLSessionHTTPClient`, validates the HTTP status code (200–299) and maps failures to typed `APIError` cases.
- **`APIClient`** — responsible for building a typed `Endpoint` into a `URLRequest` (via `RequestBuilding`), forwarding it to the `HTTPClient`, and decoding the response into the expected model.

Endpoints are modelled as enum cases conforming to `Endpoint`, which declare the HTTP method, path, and query parameters. This keeps the networking layer open for extension — adding a new endpoint requires no changes to the transport or decoding logic.

**Base URL:** `https://api.thecatapi.com/v1`  
**Pagination:** `GET /breeds?limit=10&page={n}` — zero-indexed, 10 breeds per page.

---

## Data Flow & Offline Support

The single source of truth for the UI is always **local storage (SwiftData)**. The remote API is used exclusively to refresh that local store. The `BreedsRepository` enforces this contract:

### On network success

```
Remote fetch ✅
    └── page == 0?
        ├── YES → deleteAllBreeds()   (wipe stale cache from previous session)
        └── NO  → (skip full wipe, preserve other cached pages)
    └── saveBreeds(remotePage, page)  (persist fresh data)
    └── fetchBreeds(page)             (read back from local)
    └── return local result           ← UI always sees local data
```

Wiping all cached pages only when page 0 is successfully fetched is a deliberate trade-off. Page 0 is always the first request made — either on initial load or on pull-to-refresh. A successful fetch of page 0 proves the device has a live network connection and that the API returned fresh data, so it is the right moment to discard whatever was stored from a previous session. Pages beyond 0 are cached individually as the user paginates, and they are overwritten naturally on each successful remote fetch for that page.

### On network failure

```
Remote fetch ❌
    └── fetchBreeds(page)             (read from local cache)
    └── cache empty? → throw          (no data to show)
    └── cache has data? → return it   ← UI shows last known state
```

The local cache is never written to or modified on a network failure. This ensures that a failed refresh or a lost connection mid-scroll cannot corrupt the cached state.

### Favourite persistence

Favourites are stored separately in a `FavoriteBreedEntity` SwiftData model. They survive app restarts independently of the breed cache and are loaded at app launch by `AppFeature`, which then synchronises the `isFavorite` flag across both the breeds list and the favourites tab.

---

## Image Caching

Images are loaded and cached using **Nuke**, configured with:

- A named **disk cache** (`"cat-breeds-images"`) so breed images are available offline after the first load.
- An **in-memory cache** (`ImageCache`) for fast re-display during a session.
- **Task coalescing** — concurrent requests for the same URL are deduplicated into a single network call.
- **Rate limiting** — prevents request storms when the list scrolls rapidly.

---

## Key Libraries

| Library | Purpose |
|---|---|
| [swift-composable-architecture](https://github.com/pointfreeco/swift-composable-architecture) | Application architecture |
| [Nuke](https://github.com/kean/Nuke) | Async image loading and caching |

Both are integrated via **Swift Package Manager**.

---

## Testing

The project has three levels of test coverage:

- **Unit tests** — `FavoritesFeature` reducer logic, including average lifespan edge cases.
- **Feature integration tests** — `BreedsListFeature` and `AppFeature` are tested using TCA's `TestStore`, which enforces exhaustive assertions on every state change and every received action. This catches any unintended side effect.
- **Repository tests** — `BreedsRepositoryTests` uses actor-based spies (`RemoteBreedsDataSourceSpy`, `LocalBreedsDataSourceSpy`) to verify the caching and fallback logic in isolation, including: cache invalidation on page 0 success, per-page caching for subsequent pages, offline fallback for any page, and correct `hasNextPage` inference from cache size.

---

## Features

- Browse the full catalogue of cat breeds with infinite scroll pagination
- Search and filter breeds by name
- View detailed breed information: name, origin, temperament, description, and lifespan
- Mark breeds as favourites from the list or the detail screen
- Favourites screen with the average lifespan across all saved breeds
- Full offline support — previously loaded pages remain accessible without a connection
- Pull-to-refresh to sync with the latest data from the API
