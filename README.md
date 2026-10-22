# Elppa - Extended Local Prediction and Precipitation Application

Rails 8 app with PostgreSQL, Redis, and Sidekiq. Search weather by zip code from the navbar; results show current conditions and a 7-day forecast.

## API providers

Weather data comes from [Open-Meteo](https://open-meteo.com/). That API requires latitude and longitude, not a zip code. To keep the UI based on zip code, the app first calls [OpenStreetMap Nominatim](https://nominatim.openstreetmap.org/) to geocode the zip code (and optional country code) into coordinates, then asks Open-Meteo for the forecast.

Flow:

1. Look up the zip code on OpenStreetMap (Nominatim search by postal code).
2. Take latitude and longitude from that response.
3. Request the forecast from Open-Meteo with those coordinates.

These providers were chosen so the project can run with as little setup as possible. Both are usable without creating an account or obtaining an API key.

## Cache

Successful weather lookups are cached by zip code and country code.

- TTL is the constant `CACHE_TTL` in `Api::V1::FetchWeatherDataService` (currently 30 minutes).
- Errors are not cached.
- The weather index shows a small `from cache` / `not from cache` label next to the result.

## Architecture

Domain work lives in services rather than fat controllers. That choice is about:

- **Decoupling** — HTTP, geocoding, and weather fetching stay in separate objects.
- **Testability** — each service can be exercised in isolation, including with a fake cache or provider.
- **Predictability** — every service is invoked the same way (`call`) and returns `result` plus `errors`.
- **Control** — the orchestration service decides order, caching, and which provider to use.

`ServiceInterface` is the shared contract: subclasses implement `run`, expose `result` and `errors`, and are called through `.call`.

Composition wires the pieces together. `FetchWeatherDataService` depends on a coordinates fetcher and a weather fetcher; each fetcher receives a provider. Defaults are OpenStreetMap and Open-Meteo, but a new provider that follows the same interface can be swapped in without changing the rest of the flow.

## Docker Compose

Copy the development env file and start the stack:

```sh
cp .env.development.example .env
docker compose up --build
```

Compose builds `web` and `worker` from `Dockerfile`. The image keeps `build-essential` so development gems can compile.

Services:

- `db` — PostgreSQL 18 (`elppa_development`)
- `redis` — Redis 7
- `web` — Rails on http://localhost:3000
- `worker` — Sidekiq (dashboard at http://localhost:3000/sidekiq, Basic Auth via `SIDEKIQ_WEB_USERNAME` / `SIDEKIQ_WEB_PASSWORD`)

Postgres is published on `DB_HOST_PORT` (default 5432). Redis is on 6379.

Production Compose values live in `.env.production.example`. Copy that to `.env.production` and fill in `RAILS_MASTER_KEY` from `config/master.key`. Do not overwrite the development `.env`.

## Observations and improvements

This project had about two days of development, so it is closer to a proof of concept than a finished product. The structure is already there to grow into one: services, provider composition, cache, Docker, and tests. What is still missing is product depth.

Examples of follow-up work:

- User registration, authentication, and persisted accounts — PostgreSQL is already in the stack and waiting for that kind of feature.
- Saving favorite locations, search history, or notification jobs on Sidekiq.
- A richer UI, stronger input validation, and more provider coverage.

The current weather flow is the vertical slice. Persistence and user-facing product features are the next layer, not a rewrite.

## Tests

From inside the 'web' docker container:
```sh
bundle exec rspec
```

