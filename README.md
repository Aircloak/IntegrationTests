## Aircloak system tests

This repository contains a very simple test harness which verifies that our infrastructure is functioning properly.

The files are installed at `srv-76-131:/aircloak/tests/integration`. All output is logged in the `logs` folder.
In case of errors, check the log entries, grouped by days, for details. Use the `deploy.sh` script to upload
the latest files to the tests server.

The tests here are executed on `srv-76-131`, from Monday to Friday at 7:30 AM CET, by a cron job.
Use `crontab -e` to change the tests's execution time.

You can also run the tests manually at any time by executing the `run.sh` script.
This script will also build and deploy the latest version of the air and cloak components before executing the tests.

### Backend system tests

You can edit the [configuration file](./backend/config.json) to add more tests or change the target machines.
When adding a new test, check that the expected results are sensible.

There are 2 types of tests being executed:
  - First, load testing is performed, which executes multiple, memory hungry queries in parallel.
  - Second, the tests that verify the cloak is functioning normally are performed.

If errors are encountered, a notification email is sent to the address specified in the configuration file.

__NOTE__: Because of the way queries are executed (polling is used to wait for a query to complete),
timing information is accurate only within 1% of the test timeout value or 2 seconds, whichever is greater.
