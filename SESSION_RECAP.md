# Session Recap

Track is a Rails 8 time-tracking and invoicing app backed by PostgreSQL. It runs locally through Docker Compose, with separate Rails, PostgreSQL, and Tailwind CSS watcher services. Styling uses Tailwind CSS v4.

## Current functionality

- Projects hold client details, an hourly rate, and active/archived state.
- Time entries support starting/stopping a single timer, adding manual time, editing start and stop times, deleting uninvoiced entries, restarting an entry, and filtering records by date.
- Entries progress from `uninvoiced` to `pending` when their invoice is issued, then to `paid` when it is paid. Invoiced entries cannot be edited or deleted.
- Invoices are created for a project and date range, can be issued, paid, voided, and downloaded as PDFs. Issuing snapshots client and business details.

## Service budgets

- Each project can define its own service budgets from the project edit page.
- A budget has a name, an allowance in hours, and a cadence of either **Project total** or **Per month**. Budgets can be archived without removing historic data.
- Time entries can optionally be assigned to a category (a service budget). Category assignment is available while starting, manually adding, editing, or restarting an entry.
- Invoice screens and PDFs show budget allowance, used time, remaining time or overage, and percentage used.
- Project-total budgets count all categorised completed time through the invoice end date. Monthly budgets reset on calendar months; cross-month invoices show a row for each relevant month.
- Draft invoices calculate budget use live. Issued, paid, and voided invoices use snapshots taken at issue time, so historic invoices remain unchanged when budgets are later edited.

## Recent category-save fix

The time-entry update path now loads category choices for both edit and failed-update renders. A request-level regression test submits an edit form with a selected category and confirms the association persists.

## Verification

The test suite was last run in Docker with:

```sh
docker compose exec -e RAILS_ENV=test \
  -e DATABASE_URL=postgresql://track:track@db:5432/track_test \
  web ./bin/rails test
```

Result: 12 tests, 40 assertions, no failures.
