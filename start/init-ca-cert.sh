#!/usr/bin/env bash

# Запускать из под root

# Скрипт будет создавать корневой сертификат для настройки шифрование между узлами elastic в кластере.
# Настройка минимальной безопасности!!

cd ../
path=${PWD}/ca-stack-cluster;

if [[ -d ${path} ]]
then
    rm -R ${path}
fi

docker run  --rm -e "discovery.type=single-node" \
    -v "${path}":/opt \
    -w /usr/share/elasticsearch/bin/ \
    elasticsearch:7.17.7 \
bash -c "elasticsearch-certutil ca --pass ''  --out /opt/elastic-stack-ca.p12"