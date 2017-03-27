.PHONY: test deps start_deps

deps:
	yarn install

start_deps:
	./start_dependencies.sh

test: deps start_deps
	node_modules/.bin/wdio wdio.conf.js
