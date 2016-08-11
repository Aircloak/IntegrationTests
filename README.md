## Aircloak integration tests

This repository contains a very simple test harness which verifies that our infrastructure is functioning properly.

The tests here are executed on `srv-76-131`, from Monday to Friday at 7:30 AM CET, by a cron job.
Use `crontab -e` to change the tests's execution time.

The files are installed at `srv-76-131:/aircloak/tests/integration`. All output is logged in the `logs` folder.
In case of errors, check the log entries, grouped by days, for details.

You can edit the [configuration file](config.json) to add more tests or change the target machines.
When adding a new test, check that the expected results are sensible. Also, please record the real
results and the number of users selected. These values are not used (yet), but they can be valuable
in case someone needs to investigate a failure during the test.

If errors are encountered, a notification email is sent to the address specified in the configuration file.

You can also run the tests manually at any time by executing the `run.sh` script.

__NOTE__: Because of the way queries are executed (polling is used to wait for a query to complete),
timing information is accurate only within 1% of the test timeout value or 2 seconds, whichever is greater.
