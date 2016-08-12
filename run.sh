#!/bin/bash

cd "$(dirname "$0")"
export http_proxy=""
./main.rb 2>&1 | tee -a "./logs/`date +%F.log`"
./perf.rb
