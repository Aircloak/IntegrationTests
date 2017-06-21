#!/bin/bash

cd "$(dirname "$0")"

scp main.rb real.json Gemfile Gemfile.lock srv-76-131:/aircloak/tests/integration/backend/
