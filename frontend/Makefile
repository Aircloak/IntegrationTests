.PHONY: test

deps:
	yarn install

start_deps:
	./start_dependencies.sh

test:
	node_modules/.bin/wdio wdio.conf.js
