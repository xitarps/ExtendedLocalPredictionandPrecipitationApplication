# Elppa - Extended Local Prediction and Precipitation Application

Rails 8 app with PostgreSQL, Redis, and Sidekiq.

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
- `worker` — Sidekiq

Postgres is published on `DB_HOST_PORT` (default 5432). Redis is on 6379.

Production Compose values live in `.env.production.example`. Copy that to `.env.production` and fill in `RAILS_MASTER_KEY` from `config/master.key`. Do not overwrite the development `.env`.

