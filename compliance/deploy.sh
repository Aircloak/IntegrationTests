#!/bin/bash

cd "$(dirname "$0")"

scp -r config.json main.rb queries srv-76-131:/aircloak/tests/integration/compliance
