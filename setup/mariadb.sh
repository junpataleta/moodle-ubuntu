#!/bin/bash

source "$(pwd)/config.sh"

docker run --detach --name mariadb${MARIADB_TAG} -e MARIADB_ROOT_PASSWORD=${MARIADB_PASSWD} -p ${MARIADB_PORT}:3306 mariadb:${MARIADB_TAG}
