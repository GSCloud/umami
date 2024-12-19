#@author Fred Brooker <git@gscloud.cz>
include .env

run ?=
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
	@echo "\n\e[1;32mUmami in Docker 👾\e[0m v1.11 2024-12-18\n"
	@echo "\e[0;1m📦️ UMAMI\e[0m \t $(umdot) \e[0;4m${UMAMI_CONTAINER_NAME}\e[0m \t🚀 http://localhost:${UMAMI_PORT}"
	@echo "\e[0;1m📦️ DB\e[0m \t\t $(dbdot) \e[0;4m${UMAMI_DB_CONTAINER_NAME}\e[0m"
	@echo ""

	@echo " - \e[0;1m install\e[0m - install containers"
	@echo " - \e[0;1m start\e[0m - start containers"
	@echo " - \e[0;1m stop\e[0m - stop containers"
	@echo " - \e[0;1m test\e[0m - test containers"
	@echo " - \e[0;1m kill\e[0m - kill containers"
	@echo " - \e[0;1m remove\e[0m - remove containers"
	@echo " - \e[0;1m backup\e[0m - backup database"
	@echo " - \e[0;1m restore\e[0m - restore database"
	@echo " - \e[0;1m exec\e[0m - run interactive shell"
	@echo " - \e[0;1m exec run='<command>'\e[0m - run <command> in shell"
	@echo " - \e[0;1m debug\e[0m - run interactively"
	@echo " - \e[0;1m config\e[0m - display configuration"
	@echo " - \e[0;1m logs\e[0m - display logs"
	@echo " - \e[0;1m purge\e[0m - delete persistent data ❗️"
	@echo " - \e[0;1m docs\e[0m - transpile documentation into PDF"
	@echo ""

docs:
	@find . -maxdepth 1 -iname "*.md" -exec echo "converting {} to ADOC" \; -exec docker run --rm -v "$$(pwd)":/data pandoc/core -f markdown -t asciidoc -i "{}" -o "{}.adoc" \;
	@find . -maxdepth 1 -iname "*.adoc" -exec echo "converting {} to PDF" \; -exec docker run --rm -v $$(pwd):/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf -a allow-uri-read -d book "{}" \;
	@find . -maxdepth 1 -iname "*.adoc" -delete

debug:
	@docker compose up

install: remove
	@date
	@echo "installing containers"
	@docker compose up -d
	@echo "\n\e[0;1m📦️ Umami\e[0m: 🚀 http://localhost:${UMAMI_PORT}\n"
	@date

start:
	@echo "starting containers"
	@docker start ${UMAMI_CONTAINER_NAME}
	@docker start ${UMAMI_DB_CONTAINER_NAME}

stop:
	@echo "stopping containers"
	@-docker stop ${UMAMI_CONTAINER_NAME}
	@-docker stop ${UMAMI_DB_CONTAINER_NAME}

kill:
	@echo "😵"
	@docker compose kill

remove:
	@echo "removing containers"
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
	@echo "🟢 Umami is up"
else
	@echo "🔴 Umami is down"
endif
ifneq ($(strip $(db_status)),)
	@echo "🟢 DB is up"
else
	@echo "🔴 DB is down"
endif
ifneq ($(umdb_status), $(umdbok))
	@exit 255
else
	@exit 0
endif
