#!/bin/bash

source "$(pwd)/config.sh"

sudo apt install -y mysql-client

docker run --name mysqli${MYSQLI_TAG} -e MYSQL_ROOT_PASSWORD=${MYSQLI_PASSWD} -p ${MYSQLI_PORT}:3306 -d mysql:${MYSQLI_TAG}
