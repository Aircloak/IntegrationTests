#!/bin/bash

cd "$(dirname "$0")"

# make and publish nightly build
echo "Deploying nightly build ..."
if [ -f ./logs/deploy.log ]; then
  mv ./logs/deploy.log ./logs/deploy.old.log
fi
if ! (set -o pipefail && cd aircloak && git pull && ./publish.sh nightly 2>&1 | tee "../logs/deploy.log") ; then
  mail everyone-dev@aircloak.com -aFrom:everyone-dev@aircloak.com -s "Nightly deploy failed :(" < "./logs/deploy.log"
  echo "Nightly build failed! Notification email sent."
  exit
fi

# make and publish browser_test build
echo "Deploying browser-test..."
if [ -f ./logs/deploy.log ]; then
  mv ./logs/deploy.log ./logs/deploy.old.log
fi
if ! (cd aircloak && git pull && ./publish.sh browser_test 2>&1 | tee "../logs/deploy.log") ; then
  mail everyone-dev@aircloak.com -aFrom:everyone-dev@aircloak.com -s "Browser-test deploy failed :(" < "./logs/deploy.log"
  echo "Browser-test build failed! Notification email sent."
  exit
fi

echo "Deploy complete! Waiting 90 seconds for airs/cloaks to stabilise ..."
sleep 90

export http_proxy=""
LOG="./logs/`date +%F.log`"

# execute backend system tests
./backend/main.rb 2>&1 | tee -a "$LOG"

# execute compliance tests
./compliance//main.rb 2>&1 | tee -a "$LOG"

# execute browser tests
./frontend/run.sh
