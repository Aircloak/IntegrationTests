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

echo "Deploy complete! Waiting 90 seconds for nightly air/cloak to stabilise ..."
sleep 90

# execute integration and performance regression tests
export http_proxy=""
LOG="./logs/`date +%F.log`"
./main.rb 2>&1 | tee -a "$LOG"
./perf.rb 2>&1 | tee -a "$LOG"
