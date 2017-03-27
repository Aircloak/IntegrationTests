#!/bin/bash

cd "$(dirname "$0")"

scp main.rb config.json srv-76-131:/aircloak/tests/integration/backend/
