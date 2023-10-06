#@author Fred Brooker <git@gscloud.cz>
include .env

has_php != command -v php 2>/dev/null
um_status != docker inspect --format '{{json .State.Running}}' ${UMAMI_CONTAINER_NAME} 2>/dev/null | grep true
db_status != docker inspect --format '{{json .State.Running}}' ${UMAMI_DB_CONTAINER_NAME} 2>/dev/null | grep true
umdb_status := $(um_status)$(db_status)
umdbok = truetrue
run ?=

ifneq ($(strip $(um_status)),)
umdot=🟢
else
umdot=🔴
endif

ifneq ($(strip $(db_status)),)
dbdot=🟢
else
dbdot=🔴
endif


all: info
info:
	@echo "\n\e[1;32mUmami in Docker 👾\e[0m v1.1 2023.09.23\n"
	@echo "\e[0;1m📦️ Umami\e[0m container: \t $(umdot) \e[0;4m${UMAMI_CONTAINER_NAME}\e[0m \t🚀 http://localhost:${UMAMI_PORT}"
	@echo "\e[0;1m📦️ DB\e[0m container: \t $(dbdot) \e[0;4m${UMAMI_DB_CONTAINER_NAME}\e[0m"
	@echo ""
	@echo " - \e[0;1m pull\e[0m - update Umami image to ${UMAMI_IMAGE}"
	@echo " - \e[0;1m install\e[0m - install containers"
	@echo " - \e[0;1m start\e[0m - start containers"
	@echo " - \e[0;1m stop\e[0m - stop containers"
	@echo " - \e[0;1m pause\e[0m - pause containers"
	@echo " - \e[0;1m unpause\e[0m - unpause containers"
	@echo " - \e[0;1m kill\e[0m - kill containers"
	@echo " - \e[0;1m test\e[0m - test containers, force reinstall"
	@echo " - \e[0;1m stop\e[0m - stop containers"
	@echo " - \e[0;1m backup\e[0m - backup database"
	@echo " - \e[0;1m restore\e[0m - restore database"
	@echo " - \e[0;1m remove\e[0m - remove containers"
	@echo " - \e[0;1m debug\e[0m - install containers, run interactively"
	@echo " - \e[0;1m exec\e[0m - run shell inside Umami container"
	@echo " - \e[0;1m exec run='<command>'\e[0m - run <command> inside Umami container"
	@echo " - \e[0;1m config\e[0m - display Docker compose configuration"
	@echo " - \e[0;1m jsoncontrol\e[0m - display a set of make control commands in JSON format"
	@echo " - \e[0;1m logs\e[0m - display logs"
	@echo " - \e[0;1m purge\e[0m - delete persistent data ❗️"
	@echo " - \e[0;1m docs\e[0m - build documentation into PDF format"
	@echo ""

jsoncontrol:
ifneq ($(strip $(has_php)),)
	@php -r 'echo json_encode(["control_set" => ["backup", "config", "debug", "exec", "install", "kill", "logs", "pause", "purge", "remove", "restore", "start", "stop", "test", "unpause"]], JSON_PRETTY_PRINT);'
else
	@echo "❗️ php parser is not installed"
	@exit 99
endif

docs:
	@echo "🔨 \e[1;32m Building documentation\e[0m"
	@bash ./bin/create_pdf.sh

pull:
	@docker pull ${UMAMI_IMAGE}

debug:
	@docker compose up

install:
	@echo "\nINSTALL\n"
	@docker compose up -d
	@echo "\n\e[0;1m📦️ Umami\e[0m: 🚀 http://localhost:${UMAMI_PORT}\n"

start:
	@echo "\nSTART\n"
	@docker start ${UMAMI_CONTAINER_NAME}
	@docker start ${UMAMI_DB_CONTAINER_NAME}

stop:
	@echo "\nSTOP\n"
	@-docker stop ${UMAMI_CONTAINER_NAME}
	@-docker stop ${UMAMI_DB_CONTAINER_NAME}

kill:
	@docker compose kill

pause:
	@echo "⏯️"
	@docker compose pause

unpause:
	@echo "⏯️"
	@docker compose unpause

remove:
	@-docker compose rm ${UMAMI_CONTAINER_NAME} --force 2>/dev/null
	@-docker compose rm ${UMAMI_DB_CONTAINER_NAME} --force 2>/dev/null

config:
	@docker compose config

exec:
ifneq ($(strip $(run)),)
	@docker exec -it ${UMAMI_CONTAINER_NAME} $(run)
else
	@docker exec -it ${UMAMI_CONTAINER_NAME} sh
endif

logs:
	@docker logs -f ${UMAMI_CONTAINER_NAME}

backup:
	@echo "\nBACKUP\n"
	@date
	@docker compose down
	@rm -rf bak
	@mkdir bak
ifneq ($(shell id -u),0)
	@echo "root permission required"
endif
	@sudo tar czf bak/umami-db-data.tgz umami-db-data
	@cp Makefile bak/
	@cp .env bak/
	@cp docker-compose.yml bak/
	@echo "\nSTART\n"
	@docker compose up -d
	@date

restore: remove
	@echo "\nRESTORE\n"
	@date
ifneq ($(shell id -u),0)
	@echo "root permission required"
endif
	@sudo rm -rf umami-db-data
ifneq ($(wildcard ./bak/.),)
	@echo "backup location: bak"
ifneq ($(wildcard bak/umami-db-data.tgz),)
	@-sudo tar xzf bak/umami-db-data.tgz 2>/dev/null
else
	@echo "❗️ missing database archive"
	exit 1
endif
else
	@echo "backup location: ."
ifneq ($(wildcard umami-db-data.tgz),)
	@-sudo tar xzf umami-db-data.tgz 2>/dev/null
else
	@echo "❗️ missing database archive"
	exit 1
endif

endif
	@-make install
	@date

purge:
	@echo "\nPURGE\n"
	@-docker rm ${UMAMI_CONTAINER_NAME}_static --force 2>/dev/null
	@-docker rm ${UMAMI_DB_CONTAINER_NAME}_static --force 2>/dev/null
	@echo "💀 deleting permanent storage"
ifneq ($(shell id -u),0)
	@echo "root permission required"
endif
	sudo rm -rf umami-db-data

test:
ifneq ($(strip $(um_status)),)
	@echo "🟢 Umami is up and running or paused"
else
	@echo "🔴 Umami is down"
endif
ifneq ($(strip $(db_status)),)
	@echo "🟢 DB is up and running or paused"
else
	@echo "🔴 DB is down"
endif
ifneq ($(umdb_status), $(umdbok))
	@-make install
	@exit 1
else
	@exit 0
endif
