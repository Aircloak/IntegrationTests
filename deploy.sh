#!/bin/bash

cd "$(dirname "$0")"

scp run.sh srv-76-131:/aircloak/tests/integration/

./backend/deploy.sh # backend files
./frontend/deploy.sh # frontend files
./compliance/deploy.sh # compliance files

# Deploy common files
scp -r common srv-76-131:/aircloak/tests/integration/
