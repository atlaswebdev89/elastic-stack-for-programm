#!/usr/bin/env bash

# Скрипт для формирование паролей для встроенных пользователей в elastic
# Полученные пароли сохраняются в файл и нужны для настройки kibana и других сервисов
# Первым параметром передаем название одной из нод в cluster

# Работает при настроеном кластере

if ! [[ -z $1 ]]
then
    HOST=$1
else 
    echo "Not set name host"
    exit 0
fi

/usr/bin/expect <<END
    set timeout 120
    spawn docker exec -it ${HOST} bash -c "cd bin/ && elasticsearch-setup-passwords auto"
            expect {
                    "*\]" { 
                            log_file passwords.txt
                            send -- "y\r" 
                            expect "dfrc"
                    }
                } 
END

if [[ -f passwords.txt ]]
then
    cd ..  
    rm -R elastic-stack-passwords 
    mkdir elastic-stack-passwords
    mv ${PWD}/get-password/passwords.txt elastic-stack-passwords
else
    echo "file password not found"
    exit 1
fi

exit 0