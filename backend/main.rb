#!/usr/bin/env ruby

# Backend system tests

require "rubygems"
require "bundler/setup"
require "json"
require 'rest_client'
require 'net/smtp'
require 'date'
require 'cgi'

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

def start_query(url, api_token, datasource, statement)
  body = {
    query: {
      statement: statement,
      data_source_token: datasource
    }
  }.to_json
  request = {
    method: :post,
    url: "#{url}/api/queries",
    headers: {
      'auth-token' => api_token,
      'content-Type' => "application/json"
    },
    payload: body
  }
  response = RestClient::Request.execute(request)
  JSON.parse response.body
end

def get_query(url, api_token, query_id)
  request = {
    method: :get,
    url: "#{url}/api/queries/#{query_id}",
    headers: {
      'auth-token' => api_token
    }
  }
  response = RestClient::Request.execute(request)
  query = JSON.parse response.body
  query = query["query"]
end

def execute_query(url, api_token, datasource, statement, timeout)
  start_time = Time.now
  print "."
  query = start_query(url, api_token, datasource, statement)
  if !query["success"] then raise "Failed to start query" end
  query_id = query["query_id"]

  poll_interval = [(timeout / 100).round(), 2].max()
  progress = duration = 0
  begin
    sleep poll_interval
    progress += 1
    if progress % 5 == 0 then print "." end
    query = get_query(url, api_token, query_id) # get current state
    duration = (Time.now - start_time).round()
  end until query["completed"] or duration > timeout

  if duration > timeout then raise "Query timeout (duration exceeded #{timeout} seconds)" end
  if query["error"] then raise query["error"] end
  # Note: This log line is used by the perf.rb script to extract timing information.
  # If you modify it, you must update the parsing code in that file also.
  puts(" completed in #{duration} seconds.")

  query["rows"].map do |row|
    row["row"].map do |value|
      if value.is_a?(Float) then
        (value * 1000).round() / 1000.0 # keep 3 decimals at most (just like the UI)
      else
        value
      end
    end
  end
end

def cancel_query(url, api_token, query_id)
  request = {
    method: :post,
    url: "#{url}/api/queries/#{query_id}/cancel",
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
    sleep $sleep
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
  sleep $sleep
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
$sleep = config["sleep"]

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
  if config["email_server"] then
    Net::SMTP.start(config["email_server"], config["email_port"]) do |smtp|
      smtp.send_message message, config["email_from"], config["email_to"]
      puts("Notification email sent!")
    end
  else
    puts message
  end
end
