#!/bin/bash

cd "$(dirname "$0")"

export http_proxy=""
LOG="./logs/`date +%F.log`"
./main.rb 2>&1 | tee -a "$LOG"
./perf.rb 2>&1 | tee -a "$LOG"
