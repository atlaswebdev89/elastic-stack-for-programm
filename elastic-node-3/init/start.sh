#!/usr/bin/env bash

# Правильный часовой пояс
tz=$TZ;
if [[ -n $tz ]];
then 
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Настраиваются сертификаты доступа 
if ! [[ -z ${SECURITY} ]] && [[ ${SECURITY} == "true" ]] && ! [[ -f /usr/share/elasticsearch/config/elastic-certificates.p12 ]]
then
	if [[ -f /usr/share/elasticsearch/config/cert/elastic-stack-ca.p12 ]]
	then
		cp /usr/share/elasticsearch/config/cert/elastic-stack-ca.p12 /usr/share/elasticsearch/config/elastic-stack-ca.p12
		# создаем сертификат для ноды elastic без пароля. Нечего в keystore добавлять не надо
		/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca /usr/share/elasticsearch/config/elastic-stack-ca.p12 --ca-pass '' --out /usr/share/elasticsearch/config/elastic-certificates.p12 --pass ''
		# Изменяем права доступа к сертификатам
		chmod 775 /usr/share/elasticsearch/config/elastic-certificates.p12
		chmod 775 /usr/share/elasticsearch/config/elastic-stack-ca.p12
		echo "Setup minimal security. Certificates done!"
	else 
		echo "Not found ca certificate. You need run script init-ca-cert.sh!!"
		exit 1	
	fi
fi


# Запуст команды из под пользователя elasticsearch
su elasticsearch -c /usr/share/elasticsearch/bin/elasticsearch 




