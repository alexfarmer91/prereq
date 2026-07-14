#!/usr/bin/env bash
# Boot the dev stack (API with auth bypassed) in a Codespace or any Linux box.
#
#   DATABASE_URL set        -> use it (e.g. Supabase); migrations run at boot
#   else if docker present  -> spin up a local Postgres container
#   else                    -> boot without a DB (user features return 503)
#
# Optional: export ANTHROPIC_API_KEY first to enable AI scoring.
set -euo pipefail

if [ -n "${DATABASE_URL:-}" ]; then
  echo "Using provided DATABASE_URL"
elif command -v docker > /dev/null 2>&1; then
  docker start prereq-pg 2>/dev/null || docker run -d --name prereq-pg \
    -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=prereq postgres:16
  echo "Waiting for Postgres..."
  for i in $(seq 1 30); do
    docker exec prereq-pg pg_isready -U postgres > /dev/null 2>&1 && break
    sleep 1
  done
  export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/prereq
else
  echo "WARNING: no DATABASE_URL and no docker — booting without a database" >&2
  echo "         (markets work; watchlist/bets/performance will return 503)" >&2
fi

export SKIP_AUTH=true
export PORT="${PORT:-3000}"

cd "$(dirname "$0")/backend"
exec cargo run
