### Aircloak integration tests

This repository contains a very simple test harness which verifies that our infrastructure is functioning properly.

The tests here are executed on `srv-76-131`, from Monday to Friday at 7:30 AM CET, by a cron job.
Use `crontab -e` to change the tests's execution time.

The files are installed at `srv-76-131:/aircloak/tests/integration`. All output is logged in the `logs` folder.
In case of errors, check the log entries, grouped by days, for details.

You can edit the [configuration file](config.json) to add more tests or change the target machines.
If errors are encountered, a notification email is sent to the address specified in the same configuration file.

You can also run the tests manually at any time by executing the `run.sh` script.
