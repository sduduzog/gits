#!/bin/bash

# Get count of untracked migrations
N_MIGRATIONS=$(git ls-files --others priv/repo/migrations | wc -l)

# Rollback untracked migrations
mix ecto.rollback -n $N_MIGRATIONS

# Delete untracked migrations and snapshots
git ls-files --others priv/repo/migrations | xargs rm
git ls-files --others priv/resource_snapshots | xargs rm

# Regenerate migrations
mix ash_postgres.generate_migrations

# Run migrations if flag
if echo $* | grep -e "-m" -q
then
  mix ecto.migrate
fi
