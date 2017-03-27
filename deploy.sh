#!/bin/bash

cd "$(dirname "$0")"

scp run.sh srv-76-131:/aircloak/tests/integration/

./backend/deploy.sh # backend files
