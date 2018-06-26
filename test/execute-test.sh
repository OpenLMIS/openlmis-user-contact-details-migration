#!/usr/bin/env bash

set -e

echo "PREPARE DATABASE"
./prepare.sh

echo "EXECUTE MIGRATION"
./migrate.sh

echo "VALIDATE MIGRATED DATA"
./validate.sh
