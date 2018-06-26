#!/bin/bash

set -e

until psql -c '\q' &> null; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - executing command"

if [ -f prepare.sql ]; then
  rm prepare.sql
fi

PSQL="psql --single-transaction --set AUTOCOMMIT=off --set ON_ERROR_STOP=on --no-align -t --field-separator , --quiet"

echo "CREATE SCHEMA referencedata;" >> prepare.sql
echo "CREATE TABLE referencedata.users (id uuid NOT NULL, allownotify boolean DEFAULT true, email character varying(255) NOT NULL, verified boolean DEFAULT false NOT NULL, phoneNumber CHARACTER VARYING(255));" >> prepare.sql

echo "TRUNCATE TABLE referencedata.users;" >> prepare.sql

while IFS=, read -r id email phone verified notify ; do
  echo "INSERT INTO referencedata.users(id, phoneNumber, allowNotify, email, verified) VALUES ('${id}', '${phone}', '${notify}', '${email}', '${verified}') ;" >> prepare.sql
done < test-data.csv

echo "CREATE SCHEMA notification;" >> prepare.sql
echo "CREATE TABLE notification.user_contact_details (allownotify boolean DEFAULT true, email character varying(255) NOT NULL, emailVerified boolean DEFAULT false NOT NULL, phoneNumber CHARACTER VARYING(255), referencedatauserid uuid PRIMARY KEY);" >> prepare.sql

echo "TRUNCATE TABLE notification.user_contact_details;" >> prepare.sql

echo "Prepare database to test"
${PSQL} < prepare.sql

