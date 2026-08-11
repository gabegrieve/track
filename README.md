# Track

A private Rails time tracker and invoicing tool. It uses PostgreSQL, stores money as AUD cents, and generates invoice PDFs with configurable GST.

## Run with Docker

Docker Compose starts Rails, Tailwind's watcher, and PostgreSQL together:

```sh
docker compose up --build
```

Open `http://localhost:3000`. The first web-container start prepares the database. Stop the stack with `docker compose down`; add `--volumes` to remove local database data.

Run tests in the container with:

```sh
docker compose run --rm -e RAILS_ENV=test -e DATABASE_URL=postgresql://track:track@db:5432/track_test web bin/rails db:prepare test
```

## Run without Docker

1. Install and start PostgreSQL 16+.
2. Ensure Ruby `3.4.10` is selected (the included `.ruby-version` works with mise).
3. Run `bundle install`, then `bin/rails db:prepare`.
4. Start the app with `bin/rails server` and open `http://localhost:3000`.

Run Tailwind in one terminal with `bin/rails tailwindcss:watch`, then use `bin/rails server` in another. Run the test suite with `bin/rails test`.

Before issuing the first invoice, enter your sender and payment details under Settings. Projects contain client details and an hourly rate in cents (for example, `15000` is `$150.00/hr`).
