#!/bin/bash

set -e

PSQL="psql --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --no-align -t --field-separator , --quiet"

echo "Read user contact details (the notification database)"
${PSQL} -c "SELECT referenceDataUserId, email, phoneNumber, emailVerified, allowNotify FROM notification.user_contact_details" > migrated-data.csv

comm -23 <(sort migrated-data.csv) <(sort test-data.csv) &> missing-data.csv

if [ -s "missing-data.csv" ]; then
  echo "DATA HAVE BEEN MIGRATED INCORRECTLY"
  echo "THE FOLLOWING DATA ARE MISSING:"
  cat missing-data.csv
else
  echo "DATA HAVE BEEN MIGRATED CORRECTLY"
fi
