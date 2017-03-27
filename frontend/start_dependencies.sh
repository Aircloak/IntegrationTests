#!/bin/bash

CONTAINER_NAME=selenium
IMAGE_NAME=selenium/firefox-standalone

function named_container_running {
  if [ -z "$(docker ps --filter=name=$1 | grep -w $1)" ]; then
    return 1
  else
    return 0
  fi
}

if ! named_container_running $CONTAINER_NAME ; then
	docker run --name $CONTAINER_NAME -d -p 4444:4444 selenium/standalone-firefox:latest
fi
