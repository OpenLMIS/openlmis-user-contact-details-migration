#!/bin/bash

set -e

if [ -f migration.sql ]; then
  rm migration.sql
fi

PSQL="psql --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --no-align -t --field-separator , --quiet"

echo "Read user contact details (the reference data database)"
${PSQL} -c "SELECT id, email, phoneNumber, verified, allowNotify FROM referencedata.users" > user_contact_details.csv

echo "Create SQL statements"
echo "TRUNCATE TABLE notification.user_contact_details CASCADE;" >> migration.sql

while IFS=, read -r id email phone verified notify ; do
  if [ -n "${email##+([[:space:]])}" ]; then
      emailAddress="'${email}'"
      emailVerified="'${verified}'"
  else
      emailAddress="NULL"
      emailVerified="NULL"
  fi

  echo "INSERT INTO notification.user_contact_details(referenceDataUserId, phoneNumber, allowNotify, email, emailVerified) VALUES ('${id}', '${phone}', '${notify}', ${emailAddress}, ${emailVerified}) ;" >> migration.sql
done < user_contact_details.csv

echo "Apply migration (the notification database)"
${PSQL} < migration.sql
