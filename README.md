

# Итоговый проект онлайн-курса OTUS "Administrator Linux. Basic" 


# "Web-сервис с балансировкой нагрузки, репликацией данных, централизованной системой логирования и мониторинга" 



1. Описание стенда:

	В качестве примера web-сервиса используется web-сайт под управлением Wordpress. ОС CentOS 7.
	
	Для развертывания всех компонентов web-сервиса использован VirtualBox, с помощью которого разворачивается стенд, состоящий из 6-ти виртуальных машин с предустановленными статическими IP-адресами и типом подключения "Сетевой мост", а также установленным Git:
	
	
	192.168.0.101 - frontend web-сервиса 
	
	192.168.0.102 - backend web-сервиса 
	
	192.168.0.111 - сервер базы данных 
	
	192.168.0.112 - сервер репликации данных 
	
	192.168.0.121 - сервер централизованного логирования
	
	192.168.0.122 - сервер централизованного мониторинга
	
	
	Для устойчивой работы всех компонентов стенда на виртуальные машины необходимо установить следующие сервисы:
	
1.1. Frontend web-сервиса:
		
	Nginx - web-сервер, работающий в режиме reverse-proxy
	Filebeat - клиент сбора и передачи логов
	Node-exporter - клиент сбора и передачи телеметрии

1.2. Backend web-сервиса:

	Apache - web-сервер, работающий в режиме backend
	PHP - препроцессор гипертекста
	Wordpress - система управления содержимым сайта (cms)
	Filebeat - клиент сбора и передачи логов
	Node-exporter - клиент сбора и передачи телеметрии

1.3. Cервер базы данных:
		
	MySQL - система управления базами данных, работающая в режиме master
	Filebeat - клиент сбора и передачи логов
	Node-exporter - клиент сбора и передачи телеметрии
	
1.4. Сервер репликации данных:
	
	MySQL - система управления базами данных, работающая в режиме slave
	Filebeat - клиент сбора и передачи логов
	Node-exporter - клиент сбора и передачи телеметрии
	
1.5. Сервер централизованного логирования:
	
	Java - программная платформа Java
	Elasticsearch - центральный сервер сбора логов
	Logstash - клиент сбора, фильтрации и нормализации логов
	Kibana - сервер визуализации логирования
	Node-exporter - клиент сбора и передачи телеметрии
	
1.6. Сервер централизованного мониторинга:

	Prometheus - центральный сервер сбора телеметрии
	Grafana - сервер визуализации телеметрии



2. Запуск web-сервиса 


2.1. Установим MySQL и настроим репликацию master-slave, автоматическое резервное копирование данных используя Cron, а также агенты сбора логов и телеметрии Filebeat и Node-exporter.

2.1.1 На 192.168.0.111 выполним:

	git clone https://github.com/aastlt/mysql-m.git

Для репликации будет создан пользователь 'repl' с паролем 'Replpass1$':

	bash /root/mysql-m/master-install.sh

Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит MySQL, настроит master-репликацию, установит и запустит Filebeat и Node-exporter. Также выведет на экран временный пароль пользователя 'root', который необходимо сменить в интерактивном режиме для дальнейшей работы. Для удобства сменим пароль на 'Testpass1$'. 
	
По окончании работы скрипта на экран выведутся данные о позиции бинлога.
	
2.1.2. На 192.168.0.112 выполним:

	git clone https://github.com/aastlt/mysql-s.git

	bash /root/mysql-s/slave-install.sh

Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит MySQL, установит и запустит Filebeat и Node-exporter. Также выведет на экран временный пароль пользователя 'root', который необходимо сменить в интерактивном режиме для дальнейшей работы. Для удобства сменим пароль на 'Testpass1$'.

2.1.3. Используя данные позиции бинлога mysql-master в качестве аргумента, на 192.168.0.112 выполним:

	bash /root/mysql-s/repl.sh <position>

Скрипт настроит slave-репликацию. Также добавит задачу в Cron для автоматического резервного копирования базы данных Wordpress ежедневно в 02:30. Резервные копии хранятся в течение недели, далее перезаписываются.

2.1.4. Проверим статус репликации - на 192.168.0.112 выполним:

	echo "SHOW SLAVE STATUS\G" | mysql -uroot -p'Testpass1$'


2.2. Настроим MySQL на работу с Wordpress.

2.2.1. На 192.168.0.111 выполним:

Для работы Wordpress будет создана база данных 'wpdb' и пользователь 'wpuser' с паролем 'Passw0_rd' (Изменить эти данные можно внеся изменения в скрипт mysql-wordpress.sh на 192.168.0.111 и конфигурационный файл wordpress/wp-config.php на 192.168.0.102 перед началом установки): 

	bash /root/mysql-m/mysql-wordpress.sh

2.2.2. Восстановим данные web-сервиса из заранее созданного бэкапа рабочей версии базы - на 192.168.0.111 выполним:

	bash /root/mysql-m/recovery.sh


2.3. Настроим backend web-сервиса установив Apache и Wordpress а также агенты сбора логов и телеметрии Filebeat и Node-exporter.

2.3.1. На 192.168.0.102 выполним:

	git clone https://github.com/aastlt/backend.git

	bash /root/backend/backend-install.sh

Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит Apache, php и php-модули, установит и настроит Wordpress, установит и запустит Filebeat и Node-exporter. Также настроит балансировку нагрузки для Nginx создав три виртуальных хоста с портами 80, 81, 82.

2.3.2. Проверим доступность web-сервера набрав в браузере:

	192.168.0.102


2.4. Настроим frontend web-сервиса установив Nginx с балансировкой нагрузки через Apache а также агенты сбора логов и телеметрии Filebeat и Node-exporter.

2.4.1. На 192.168.0.101 выполним:

	git clone https://github.com/aastlt/frontend.git

	bash /root/frontend/frontend-install.sh

Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит Nginx, установит и запустит Filebeat и Node-exporter. Также настроит балансировку нагрузки через Apache.

2.4.2. Проверим доступность web-сервера набрав в браузере:

	192.168.0.101


2.5. Настроим централизованный сбор логов для nginx, apache и mysql установив ELK стек а также Node-exporter для сбора телеметрии.

2.5.1. На 192.168.0.121 выполним:

	git clone https://github.com/aastlt/elk.git

	bash /root/elk/elk-install.sh
	
Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит компоненты Java, необходимые для работы ELK, с лимитом оперативной памяти 4гб, установит и запустит Elasticsearch, Logstash и Kibana, установит и запустит Node-exporter.

2.5.2. Проверим доступность сервиса Elastic набрав в браузере:

	192.168.0.121:5601 # Необходимо некоторое время для запуска сервиса

2.5.3. Настроим web-интерфейс:

Management > Stack Management > Index patterns > Create index pattern > Name - nginxlogs-*, apachelogs, mysqllogs, mysqlslavelogs > Timestamp field - @timestamp
	
Analytics > Dashboard > Create new dashboard > Create visualization 

(Как пример для nginx: Bar horizontal > request.keyword, host.ip.keyword. Donut > slice by response, size by records)


2.6. Настроим централизованный мониторинг работы web-сервиса установив Prometheus и Grafana.

2.6.1. На 192.168.0.122 выполним:

	git clone https://github.com/aastlt/prometheus.git

	bash /root/prometheus/prometheus-install.sh

Скрипт установит доп. ПО (nano, wget, zsh), настроит Iptables, установит и запустит Prometheus и Grafana.

2.6.2. Проверим доступность сервиса Grafana набрав в браузере:

	192.168.0.122:3000

login - admin

password - admin

2.6.3. Настроим web-интерфейс:

Configuration > Data sources > Add data source > Prometheus - default, URL - http://192.168.0.122:9090 > Save & test
Dashboards > Import > 11074 (ID)

https://grafana.com/grafana/dashboards/ - поиск дашбордов



3. Резервное копирование и восстановление данных MySQL
	

3.1. Бэкап реплики базы данных mysql-slave потаблично.

3.1.1. На 192.168.0.112 выполним:

	bash /root/mysql-s/backup.sh
	
Скрипт создаст резервную копию базы данных Wordpress в директории /root/mysql-s/backup с указанием порядкового номера дня недели. 

3.1.2. Отправим данные на mysql-master - на 192.168.0.112 выполним:

	scp -r /root/mysql-s/backup/wpdb-<номер> root@192.168.0.111:/root/mysql-m/


3.2. Потабличное восстановление базы данных.

3.2.1. На 192.168.0.111 выполним:

	nano /root/mysql-m/recovery.sh # Раскомментируем создание базы и создание пользователя (по необходимости)

	bash /root/mysql-m/recovery.sh




















