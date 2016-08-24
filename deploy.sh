#!/bin/bash

cd "$(dirname "$0")"

scp config.json run.sh *.rb srv-76-131:/aircloak/tests/integration/
