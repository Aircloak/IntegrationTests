#!/bin/bash

set -eo pipefail

cd "$(dirname "$0")"

echo "Deploying browser-test..."
if [ -f ./logs/deploy.log ]; then
  mv ./logs/deploy.log ./logs/deploy.old.log
fi
if ! (cd aircloak && git pull && ./publish.sh browser_test 2>&1 | tee "../logs/deploy.log") ; then
  mail everyone-dev@aircloak.com -aFrom:everyone-dev@aircloak.com -s "Nightly deploy failed :(" < "./logs/deploy.log"
  echo "Nightly build failed! Notification email sent."
  exit
fi

echo "Deploy complete! Waiting 90 seconds for browser_test air/cloak to stabilise ..."
sleep 90

LOG="./logs/frontend-`date +%F.log`"
EMAIL="everyone-dev@aircloak.com"

. reset_db.sh

if ! make test 2>&1 | tee -a $LOG ; then
  cat $LOG | mail -s "Frontend integration tests failed" -a "From:$EMAIL" $EMAIL
fi
