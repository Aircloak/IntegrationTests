#!/bin/bash

set -o pipefail

cd "$(dirname "$0")"

LOG="./logs/frontend-`date +%F.log`"
EMAIL="everyone-dev@aircloak.com"

if ! make test 2>&1 | tee -a $LOG ; then
  cat $LOG | mail -s "Frontend integration tests failed" -a "From:$EMAIL" $EMAIL
fi
