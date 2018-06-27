#!/usr/bin/env bash

source ./settings.env
cp ../migrate.sh .

docker-compose -f docker-compose.yml pull
docker-compose build migration-test
docker-compose -f docker-compose.yml run migration-test

docker-compose -f docker-compose.yml down -v
