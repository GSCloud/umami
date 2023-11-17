# Umami Analytics in Docker and PostgreSQL

## Umami is an open source, privacy-focused alternative to Google Analytics

Umami site: [https://umami.is](https://umami.is)  
GitHub repository: [https://github.com/GSCloud/umami.git](https://github.com/GSCloud/umami.git)

## Usage

Run `make`:

- install - install containers
- start - start containers
- stop - stop containers
- pause - pause containers
- unpause - unpause containers
- test - test containers, force reinstall
- pull - pull/update Umami image: ghcr.io/umami-software/umami:postgresql-v2.8.0
- kill - kill containers
- remove - remove containers
- backup - backup database
- restore - restore database
- exec - run shell inside Umami container
- exec run='\<command\>' - run \<command\> inside Umami container
- debug - install containers, run interactively
- config - display Docker compose configuration
- jsoncontrol - display a set of make control commands in JSON
- logs - display logs
- purge - delete persistent data ❗️
- docs - transpile documentation into PDF

URL: [http://localhost:3000](http://localhost:3000)  
login: **admin**  
password: **umami**

Copy `.env-dist` to `.env` and modify the file according to your needs.

## Examples

- `make purge install` - purge everything and fresh install
- `make backup test` - make backup and test functionality
- `make purge restore` - purge everything and restore from backup
- `make logs` - show logs from the main container
- `make test` - test containers (reinstall if it failes)

---

Author: Fred Brooker 💌 <git@gscloud.cz> ⛅️ GS Cloud Ltd. [https://gscloud.cz](https://gscloud.cz)
