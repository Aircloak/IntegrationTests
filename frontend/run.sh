#!/bin/bash

cd "$(dirname "$0")"

LOG="../logs/frontend-`date +%F.log`"
EMAIL="everyone-dev@aircloak.com"

make test 2>&1 | tee -a $LOG
SUCCESS=${PIPESTATUS[0]}

if test $SUCCESS -ne 0 ; then
  cat $LOG | mail -s "Frontend integration tests failed" -a "From:$EMAIL" $EMAIL
fi
