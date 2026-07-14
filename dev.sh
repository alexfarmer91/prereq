#!/usr/bin/env bash
# Boot the full dev stack (Postgres + API, auth bypassed) inside a GitHub
# Codespace or any Linux box with Docker. Then point the Flutter app at
# port 3000. Optional: export ANTHROPIC_API_KEY first to enable AI scoring.
set -euo pipefail

docker start prereq-pg 2>/dev/null || docker run -d --name prereq-pg \
  -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=prereq postgres:16

echo "Waiting for Postgres..."
for i in $(seq 1 30); do
  docker exec prereq-pg pg_isready -U postgres > /dev/null 2>&1 && break
  sleep 1
done

export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/prereq
export SKIP_AUTH=true
export PORT=3000

cd "$(dirname "$0")/backend"
exec cargo run
