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
        apt install jq -y || yum install jq -y
        compose_version=$(curl https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
        output='/usr/local/bin/docker-compose'
        curl -L https://github.com/docker/compose/releases/download/$compose_version/docker-compose-$(uname -s)-$(uname -m) -o $output
        chmod +x $output
        
    fi
}

function port_checker() {
    while   :
    do
        port=$(shuf -i 10000-40000 -n 1)
        port_checking=$(netstat -nplt | grep $port)
        port_checkingv2=$(find ./ -type f -name "*.yaml" -exec grep '$port' {} \;)
        if [ -z "$port_checking" ]; then
            if [ -z "$port_checkingv2" ]; then
                break
            fi
        fi
    done
    
}

function pass_random() {
    while   :
    do
        pass_creat=$(openssl rand -hex 8)
        pass=$(find ./ -type f -name "*.yaml" -exec grep '$pass_creat'  {} \;)
        if [ -z "$pass" ]; then
            break
        fi
    done
    
}
function pass_root_random() {
    while :; do
        pass_root_creat=$(openssl rand -hex 10)
        pass=$(find ./ -type f -name "*.yaml" -exec grep '$pass_creat' {} \;)
        if [ -z "$pass" ]; then
            break
        fi
    done
    
}
function user_random() {
    while   :
    do
        user_creat=$(openssl rand -hex 8)
        user=$(find ./ -type f -name "*.yaml" -exec grep '$user_creat'  {} \;)
        if [ -z "$user" ]; then
            break
        fi
    done
    
}
function db_random() {
    while   :
    do
        db_creat=$(openssl rand -hex 8)
        db=$(find ./ -type f -name "*.yaml" -exec grep '$db_creat'  {} \;)
        if [ -z "$db" ]; then
            break
        fi
    done
    
}

function docker_creat_file_db() {
    touch database-$port.env
    cat > database-$port.env <<EOF
MYSQL_ROOT_PASSWORD=$pass_root_creat
MYSQL_DATABASE=tinydb
MYSQL_USER=59308f9ac60b1dbd
MYSQL_PASSWORD=95bd593661806b76
EOF
}

function docker_creat_file() {
    touch docker-compose-$port.yaml
    cat > docker-compose-$port.yaml <<EOF
version: '3'

services:
  # Database
  $db_creat:
    image: mysql:5.7
    ports:
      - '$port:3306'
    volumes:
      - db_data_$port:/var/lib/mysql
      - ./slave/my-slave2.cnf:/etc/mysql/my.cnf
      - ./slave/data/slave2:/var/lib/mysql
      - ./slave/init.sql:/docker-entrypoint-initdb.d/init.sql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    restart: always
    env_file:
      - database-$port.env # configure mysql
volumes:
  db_data_$port:
EOF
}

function ip_check()
{
    IPSK=$(curl ifconfig.io || curl ifconfig.co || curl ifconfig.me/ip)
}

function docker_start() {
    docker-compose -f docker-compose-$port.yaml up -d
}
docker_install
docker_compose_install
port_checker
pass_random
pass_root_random
user_random
db_random
docker_creat_file_db
docker_creat_file
docker_start
ip_check

printf "=========================================================================\n"
printf "                    Install complete mysql on docker                 \n"
printf "==========================================================================\n"
printf "               Please save infomation mysql connect use later            \n"
printf "     This information you can check later in the file database-$port.env \n"
printf "                 IP Public Connect:         $IPSK                         \n"
printf "                 Port:                      $port                         \n"
printf "                 Password Root:             73f183b4cfc5de10              \n"
printf "                 Password:                  95bd593661806b76                   \n"
printf "                 User Login:                59308f9ac60b1dbd                   \n"
printf "                 Database:                  tinydb                     \n"
printf "==========================================================================\n"
