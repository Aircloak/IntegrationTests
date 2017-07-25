#!/bin/bash

set -eo pipefail

HOST="139.19.208.225"
PORT=5432,
USER="air_browser_test"
NAME="air_browser_test"

export PGPASSWORD="P5-lFVjGm0b2_3QYOZu1lNGG"

psql -h $HOST -p $PORT -U $USER $NAME << EOF
  DELETE FROM RESULT_CHUNKS;
  DELETE FROM QUERIES;
  DELETE FROM GROUPS_USERS WHERE group_id NOT IN (
    SELECT id FROM GROUPS WHERE name = 'Admin');
  DELETE FROM DATA_SOURCES_GROUPS;
  DELETE FROM USERS WHERE email <> 'admin@aircloak.com';
  DELETE FROM GROUPS WHERE name <> 'Admin';
EOF
