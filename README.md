# Umami in Docker v1.11 2024-12-18

## Umami is an open source, privacy-focused alternative to Google Analytics

Umami site: [https://umami.is](https://umami.is)  
Umami repository: [https://github.com/umami-software/umami](https://github.com/umami-software/umami)  
Umami Analytics in Docker repository: [https://github.com/GSCloud/umami](https://github.com/GSCloud/umami)

## Usage

Run `make`:

- install - install containers
- start - start containers
- stop - stop containers
- test - test containers
- kill - kill containers
- remove - remove containers
- backup - backup database
- restore - restore database
- exec - run interactive shell
- exec run='\<command\>' - run \<command\> in shell
- debug - run interactively
- config - display configuration
- logs - display logs
- purge - delete persistent data ❗️
- docs - transpile documentation into PDF

URL: [http://localhost:3000](http://localhost:3000)  
login: **admin**  
password: **umami**

Copy `.env-dist` to `.env` and modify the file according to your needs.

## Examples

- `make purge install` - purge everything and fresh install
- `make backup test` - make backup and test
- `make purge restore` - purge everything and restore from backup
- `make logs` - show logs
- `make test` - test containers

---

Author: Fred Brooker 💌 <git@gscloud.cz> ⛅️ GS Cloud Ltd. [https://gscloud.cz](https://gscloud.cz)
