#@author Fred Brooker <git@gscloud.cz>
include .env

run ?=
has_php != command -v php 2>/dev/null
db_status != docker inspect --format '{{json .State.Running}}' ${UMAMI_DB_CONTAINER_NAME} 2>/dev/null | grep true
um_status != docker inspect --format '{{json .State.Running}}' ${UMAMI_CONTAINER_NAME} 2>/dev/null | grep true
umdb_status := $(um_status)$(db_status)
umdbok = truetrue

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
	@echo "\n\e[1;32mUmami in Docker 👾\e[0m v1.4 2024-01-12\n"
	@echo "\e[0;1m📦️ Umami\e[0m \t $(umdot) \e[0;4m${UMAMI_CONTAINER_NAME}\e[0m \t🚀 http://localhost:${UMAMI_PORT}"
	@echo "\e[0;1m📦️ DB\e[0m \t\t $(dbdot) \e[0;4m${UMAMI_DB_CONTAINER_NAME}\e[0m"
	@echo ""
	@echo " - \e[0;1m install\e[0m - install containers"
	@echo " - \e[0;1m start\e[0m - start containers"
	@echo " - \e[0;1m stop\e[0m - stop containers"
	@echo " - \e[0;1m pause\e[0m - pause containers"
	@echo " - \e[0;1m unpause\e[0m - unpause containers"
	@echo " - \e[0;1m test\e[0m - test containers, force reinstall"
	@echo " - \e[0;1m kill\e[0m - kill containers"
	@echo " - \e[0;1m remove\e[0m - remove containers"
	@echo " - \e[0;1m backup\e[0m - backup database"
	@echo " - \e[0;1m restore\e[0m - restore database"
	@echo " - \e[0;1m exec\e[0m - run shell inside Umami container"
	@echo " - \e[0;1m exec run='<command>'\e[0m - run <command> inside Umami container"
	@echo " - \e[0;1m debug\e[0m - install containers, run interactively"
	@echo " - \e[0;1m config\e[0m - display Docker compose configuration"
	@echo " - \e[0;1m jsoncontrol\e[0m - display a set of make control commands in JSON"
	@echo " - \e[0;1m logs\e[0m - display logs"
	@echo " - \e[0;1m purge\e[0m - delete persistent data ❗️"
	@echo " - \e[0;1m docs\e[0m - transpile documentation into PDF"
	@echo ""

jsoncontrol:
ifneq ($(strip $(has_php)),)
	@php -r 'echo json_encode(["control_set" => ["backup", "config", "debug", "exec", "install", "kill", "logs", "pause", "purge", "remove", "restore", "start", "stop", "test", "unpause"]], JSON_PRETTY_PRINT);'
else
	@echo "❗️ php parser is not installed"
	@exit 99
endif

docs:
	@echo "transpiling documentation ..."
	@bash ./bin/create_pdf.sh

debug:
	@docker compose up

install: remove
	@date
	@echo "installing containers ..."
	@docker compose up -d
	@echo "\n\e[0;1m📦️ Umami\e[0m: 🚀 http://localhost:${UMAMI_PORT}\n"
	@date
	@echo ""

start:
	@echo "starting containers ..."
	@docker start ${UMAMI_CONTAINER_NAME}
	@docker start ${UMAMI_DB_CONTAINER_NAME}

stop:
	@echo "stopping containers ..."
	@-docker stop ${UMAMI_CONTAINER_NAME}
	@-docker stop ${UMAMI_DB_CONTAINER_NAME}

kill:
	@echo "😵"
	@docker compose kill

pause:
	@echo "⏸️"
	@docker compose pause

unpause:
	@echo "▶️"
	@docker compose unpause

remove:
	@echo "removing containers ..."
	@-docker rm ${UMAMI_CONTAINER_NAME} --force 2>/dev/null
	@-docker rm ${UMAMI_DB_CONTAINER_NAME} --force 2>/dev/null

config:
	@docker compose config

exec:
ifneq ($(strip $(run)),)
	@docker exec ${UMAMI_CONTAINER_NAME} $(run)
else
	@docker exec -it ${UMAMI_CONTAINER_NAME} sh
endif

logs:
	@docker logs -f ${UMAMI_CONTAINER_NAME}

backup:
ifneq ($(shell id -u),0)
	@echo "root permission required"
	@sudo echo ""
endif
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
	@-make install
	@date

restore: remove
ifneq ($(shell id -u),0)
	@echo "root permission required"
	@sudo echo ""
endif
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

purge: remove
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
