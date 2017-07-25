#!/usr/bin/env ruby

# Backend system tests

require "rubygems"
require "json"
require 'rest_client'
require 'net/smtp'
require 'date'
require 'cgi'
require '../common/query_runner.rb'
$errors = []

def store_error(url, datasource, statement, error)
  cell_style = 'style="border: 1px solid lightgrey"'
  statement = CGI.escapeHTML(statement)
  message = <<ENDOFMESSAGE
  <tr><td #{cell_style}>Error</td><td #{cell_style}>#{error}</td></tr>
  <tr><td #{cell_style}>Target</td><td #{cell_style}>[#{url}]: #{datasource}</td></tr>
  <tr><td #{cell_style}>Query</td><td #{cell_style}>#{statement}</td></tr>
ENDOFMESSAGE
  $errors.push(message)
end

def format_mail(from, to)
  <<ENDOFMESSAGE
From: <#{from}>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: Backend system tests failed :(

<table style="border-collapse: collapse;" cellpadding="4" width="100%">
#{$errors.join("<tr><td colspan='2'>&nbsp;</td></tr>")}
</table>
<br/><hr/>
https://github.com/Aircloak/IntegrationTests/blob/master/README.md
ENDOFMESSAGE
end

def test_cloak(url, api_token, tests)
  puts("Running tests on '#{url}' ...")
  tests.each do |test|
    test["datasources"].each do |datasource|
      run_test(url, api_token, datasource, test)
    end
  end
end

def run_test(url, api_token, datasource, test)
  print "Executing query '#{test["query"]}' on '#{datasource} [#{url}]' "
  result = execute_query(url, api_token, datasource, test["query"], test["timeout"])
  if result != test["expects"] then raise "Expected: #{test["expects"]}, got: #{result}" end
rescue => error
  store_error(url, datasource, test["query"], error)
  puts(" failed: #{error}.")
  puts("Backtrace:\n\t#{error.backtrace.join("\n\t")}")
end

def cancel_query(url, api_token, query_id)
  request = {
    method: :post,
    url: "https://#{url}/api/queries/#{query_id}/cancel",
    headers: {
      'auth-token' => api_token
    }
  }
  RestClient::Request.execute(request)
end

# We execute multiple complex queries in parallel in order to try to crash the cloak.
def load_test_cloak(url, api_token, datasource, statements, timeout)
  puts("Starting load testing on '#{url}' ...")

  start_time = Time.now
  query_ids = statements.map do |statement|
    puts("Starting query '#{statement}' on '#{datasource}' ...")
    query = start_query(url, api_token, datasource, statement)
    if !query["success"] then raise "Failed to start query" end
    query["query_id"]
  end

  puts("Waiting for load tests to complete ...")

  duration = 0
  begin
    sleep 30
    print "."
    query_ids.reject! do |query_id|
      query = get_query(url, api_token, query_id) # get current state
      query["completed"]
    end
    duration = (Time.now - start_time).round()
  end until query_ids.empty? or duration > timeout
  puts("")

  if duration > timeout then
    puts("Query timeout (duration exceeded #{timeout} seconds). Cancelling queries ...")
    query_ids.each do |query_id|
      cancel_query(url, api_token, query_id)
    end
  end
  puts("Load testing completed successfully!")
  sleep 30
  return true
rescue => error
  store_error(url, datasource, "<LOAD TESTING QUERIES>", error)
  puts("Load testing failed: #{error}.")
  puts("Backtrace:\n\t#{error.backtrace.join("\n\t")}")
  return false
end


# -----------------------------------
# MAIN
# -----------------------------------

$stdout.sync = true # do not buffer output

config_file = if ARGV.length == 0 then File.dirname(__FILE__) + '/config.json' else ARGV[0] end

time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
puts("Integration tests started at #{time}, using settings from '#{config_file}'.")

file = File.read(config_file)
config = JSON.parse(file)

config["cloaks"].each do |cloak|
  load_test = cloak["load_testing"]
  if load_test_cloak(cloak["url"], cloak["token"], load_test["datasource"], load_test["queries"], load_test["timeout"])
    cloak["tests"].each do |tests_name|
      tests = config["tests"][tests_name]
      test_cloak(cloak["url"], cloak["token"], tests)
    end
  end
end

if not $errors.empty? then
  message = format_mail(config["email_from"], config["email_to"])
  Net::SMTP.start(config["email_server"], config["email_port"]) do |smtp|
    smtp.send_message message, config["email_from"], config["email_to"]
    puts("Notification email sent!")
  end
end
