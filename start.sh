#!/usr/bin/env bash

path=${PWD};
# Название любого контейнера с elastic в кластере. Нужен в скрипте для подключения
elastic="elastic-node-1"

# Скрипт настройки и запуска контейнеров ElasticSearch

# Запускаем сборку 
docker-compose down && docker volume prune

if [[ -d ${path}/start ]]
then
	cd ${path}/start
else 
	echo "Not dir start/"
	exit 1;
fi

if [[ -f "init-ca-cert.sh" ]]
then
	./init-ca-cert.sh
	cd ..
else 
	echo "Not fount file init-ca-cert.sh";
	exit 1;
fi

# Запускаем сборку 
docker-compose up -d --build
sleep 40

if [[ -d ${path}/get-password ]]
then
	cd ${path}/get-password/
else 
	echo "Not fount dir get-password/";
	exit 1;
fi 

if [[ -f "get-password.sh" ]]
then
	./get-password.sh $elastic
	count=0
	while  [[ ! -d ${path}/elastic-stack-passwords/  ]] && [[ ${count} -lt 3 ]]
		do
				((count++))
				echo "Case number ${count}"
				./get-password.sh $elastic
				sleep 10;
		done
	cd ${path}
else 
	echo "Not fount file init-ca-cert.sh";
	exit 1;
fi

sleep 5;
docker-compose ps;
exit 0;