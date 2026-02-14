# Maziwa Flow

**Maziwa Flow** helps a local milk seller track weekly/monthly sales, customer visits, payments, and send SMS reminders for outstanding balances.

## Why this project
A simple, real-world domain problem: tracking fractional litres and payments for customers who often buy on credit. Built to showcase clean Rails architecture (service objects, background jobs) and a production-grade integration with Africa's Talking for SMS notifications.

## Features
- Create customer accounts by phone number.
- Record sales with fractional litres (e.g. `1.250` L).
- Record payments (partial or full), compute outstanding balances.
- Dashboard: weekly/monthly/ custom date-range metrics (top customers, revenue, litres).
- SMS reminders via Africa's Talking for outstanding balances.
- Export sales and payments to CSV/XLSX.
- Background jobs for SMS sending / scheduled reminders.

## Tech stack
- :Rails 8
- Tailwind for UI
- Postgres
- Sidekiq + Redis for background jobs
- `africastalking-ruby` gem for SMS. 

## Quick start (developer)
```bash
# clone
git clone git@github.com:<you>/milk_ledger.git
cd milk_ledger

# env
cp .env.example .env
# fill env: DATABASE_URL or DB settings, AFRICASTALKING_USERNAME, AFRICASTALKING_API_KEY

# install deps
bundle install
yarn install # only if using node packages

# db
rails db:create db:migrate db:seed

# run dev (bin/dev runs watchers)
bin/dev
```

## Environment variables
Add the following to .env or to your host's env settings:

```
DATABASE_URL=postgres://user:pass@localhost:5432/milk_ledger_development
RAILS_ENV=development
AFRICASTALKING_USERNAME=sandbox
AFRICASTALKING_API_KEY=your_sandbox_key
AFRICASTALKING_FROM=YourShopName  # optional alphanumeric sender id
REDIS_URL=redis://localhost:6379/1
```