#!/bin/bash

function docker_install() {
    docker_check=$(which docker)
    if [ -z "$docker_check" ]; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
    fi
}

function docker_compose_install() {
    docker_compose_check=$(which docker-compose)
    if [ -z "$docker_compose_check" ]; then
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
}

function port_checker() {
    while :; do
        port=$(shuf -i 10000-40000 -n 1)
        port_checking=$(netstat -nplt | grep $port)
        if [ -z "$port_checking" ]; then
            break
        fi
    done

}

function pass_random() {
    while :; do
        pass_creat=$(openssl rand -hex 8)
        pass=$(find ./ -type f -name "*.yaml" -exec grep '$pass_creat' {} \;)
        if [ -z "$pass" ]; then
            break
        fi
    done

}
function user_random() {
    while :; do
        user_creat=$(openssl rand -hex 8)
        user=$(find ./ -type f -name "*.yaml" -exec grep '$user_creat' {} \;)
        if [ -z "$user" ]; then
            break
        fi
    done

}
function db_random() {
    while :; do
        db_creat=$(openssl rand -hex 8)
        db=$(find ./ -type f -name "*.yaml" -exec grep '$db_creat' {} \;)
        if [ -z "$db" ]; then
            break
        fi
    done

}

function docker_creat_file_db() {
    touch database-$port.env
    cat >database-$port.env <<EOF
MYSQL_ROOT_PASSWORD=$pass_creat
MYSQL_DATABASE=$db_creat
MYSQL_USER=$user_creat
MYSQL_PASSWORD=$pass_creat
EOF
}

function docker_creat_file() {
    touch docker-compose-$port.yaml
    cat >docker-compose-$port.yaml <<EOF
version: '3'

services:
  # Database
  $db_creat:
    image: mysql/mysql-server:8.0-aarch64
    ports:
      - '$port:3306'
    volumes:
      - db_data_$port:/var/lib/mysql
    restart: always
    env_file:
      - database-$port.env # configure mysql
volumes:
  db_data_$port:
EOF
}

function docker_start() {
    docker-compose -f docker-compose-$port.yaml up -d 
}
docker_install
docker_compose_install
port_checker
pass_random
user_random
db_random
docker_creat_file_db
docker_creat_file
docker_start

printf "=========================================================================\n"
printf "                    Cai dat thanh cong mysql tren docker                 \n"
printf "==========================================================================\n"
printf "              Luu lai thong tin duoi day de truy cap vao mysql            \n"
printf "                 Port:                      $port                         \n"
printf "                 Mat khau:                  $pass_creat                         \n"
printf "                 User Login:                $user_creat                         \n"
printf "                 Database:                  $db_creat                           \n"
printf "==========================================================================\n"
