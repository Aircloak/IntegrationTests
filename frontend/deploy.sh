#!/bin/bash

cd "$(dirname "$0")"

scp -r Makefile yarn.lock *.js *.json *.sh test srv-76-131:/aircloak/tests/frontend/
