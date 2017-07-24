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

### Compliance tests

We have a [compliance
test dataset](https://github.com/Aircloak/aircloak/blob/master/cloak/datagen/compliance_data_generator.rb)
that is inserted into each datasource we support and available for querying. The set of queries in the
compliance query list is executed against all datasources to ensure they all emit the same answer.

Queries should be added to test all aspects of our query system.

### Frontend tests

The tests driving the system through the frontend are contained in the `/frontend` directory. The deployed version can
be found on `srv-76-131:/aircloak/tests/frontend`. They are run an hour after the backend tests, on a separate
instance of cloak/air called `browser_test` that's deployed from master just before running the tests.

#### DB cleaning

The tests run a script (`/frontend/reset_db.sh`) that clears the database before each run. When developing you can login
to `srv-76-131` and run the script from there to get the same result.

#### Running locally

You can run the tests locally with:

```bash
make test
```

This will install node dependencies and download and run a selenium docker image before running the tests.

#### Running one file

Assuming you installed dependencies (`make deps && make start_deps`) you can run a single file with:

```bash
node_modules/.bin/wdio wdio.conf.js --spec test/file_to_run.js
```

#### Debugging

You can watch the browser while the tests run if you start a debug version of the selenium image in place of the regular
one:

```bash
# Remove current selenium
docker rm -f selenium

# Download and run the debug version mapping the VNC port 5900
docker run --name selenium -d -p 4444:4444 -p 5900:5900 selenium/standalone-chrome-debug
```

You will also need to install a VNC viewer. After that just point your viewer to localhost and provide `secret` when
asked for a password.
