#!/bin/bash

source "$(pwd)/config.sh"

sudo apt install -y postgresql-client

docker run --name pgsql${PGSQL_TAG} -e POSTGRES_PASSWORD=${PGSQL_PASSWD} -p 5432:5432 -d postgres:${PGSQL_TAG}
