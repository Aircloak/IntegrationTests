#!/usr/bin/env ruby

# Integration test

require "rubygems"
require "json"
require 'rest_client'
require 'net/smtp'
require 'date'

$errors = []

def store_error(url, cloak_id, test, error)
  cell_style = 'style="border: 1px solid lightgrey"'
  message = <<ENDOFMESSAGE
  <tr><td #{cell_style}>Error</td><td #{cell_style}>#{error}</td></tr>
  <tr><td #{cell_style}>Target</td><td #{cell_style}>#{cloak_id} / #{test["datasource"]} [#{url}]</td></tr>
  <tr><td #{cell_style}>Query</td><td #{cell_style}>#{test["query"]}</td></tr>
ENDOFMESSAGE
  $errors.push(message)
end

def format_mail(to)
  message = <<ENDOFMESSAGE
From: <no-reply@aircloak.com>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: Integration tests failed :(

<table style="border-collapse: collapse;" cellpadding="4" width="100%">
#{$errors.join("<tr><td colspan='2'>&nbsp;</td></tr>")}
</table>
<br/><hr/>
https://github.com/Aircloak/IntegrationTests/blob/master/README.md
ENDOFMESSAGE
end

def test_cloak(url, cloak_id, api_token, tests)
  puts "Running tests for cloak '#{cloak_id}' from '#{url}' ..."
  tests.each do |test| run_test(url, cloak_id, api_token, test) end
end

def run_test(url, cloak_id, api_token, test)
  # Note: This log line is used by the perf.rb script to extract timing information.
  # If you modify it, you must update the parsing code in that file also.
  print "Executing query '#{test["query"]}' on '#{cloak_id}/#{test["datasource"]}' "
  datasource_token = get_datasource_token(url, cloak_id, api_token, test["datasource"])
  result = execute_query(url, api_token, datasource_token, test["query"], test["timeout"])
  if result != test["expects"] then raise "Expected: #{test["expects"]}, got: #{result}" end
rescue => error
  store_error(url, cloak_id, test, error)
  puts " failed: #{error}."
  puts "Backtrace:\n\t#{error.backtrace.join("\n\t")}"
end

def get_datasource_token(url, cloak_id, api_token, datasource_id)
  request = {
    method: :get,
    url: "#{url}/api/data_sources",
    #verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    headers: {
      'auth-token' => api_token
    }
  }
  response = RestClient::Request.execute request
  datasources = JSON.parse response.body
  target_name = "#{datasource_id} (#{cloak_id})"
  datasources.each do |datasource|
    return datasource["token"] if datasource["display"] == target_name
  end
  raise "Datasource '#{datasource_id}' was not found at '#{url}'"
end

def start_query(url, api_token, datasource_token, statement)
  body = {
    query: {
      statement: statement,
      data_source_token: datasource_token
    }
  }.to_json
  request = {
    method: :post,
    url: "#{url}/api/queries",
    #verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    headers: {
      'auth-token' => api_token,
      'content-Type' => "application/json"
    },
    payload: body
  }
  response = RestClient::Request.execute request
  JSON.parse response.body
end

def get_query(url, api_token, query_id)
  request = {
    method: :get,
    url: "#{url}/api/queries/#{query_id}",
    #verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    headers: {
      'auth-token' => api_token
    }
  }
  response = RestClient::Request.execute request
  query = JSON.parse response.body
  query = query["query"]
end

def execute_query(url, api_token, datasource_token, statement, timeout)
  start_time = Time.now
  print "."
  query = start_query(url, api_token, datasource_token, statement)
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
  puts " completed in #{duration} seconds."

  query["rows"].map do |row|
    row["row"].map do |value|
      (value * 1000).round() / 1000.0 # keep 3 decimals at most (just like the UI)
    end
  end
end


# -----------------------------------
# MAIN
# -----------------------------------

$stdout.sync = true # do not buffer output

config_file = if ARGV.length == 0 then 'config.json' else ARGV[0] end

time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
puts "Integration tests started at #{time}, using settings from '#{config_file}'."

file = File.read(config_file)
config = JSON.parse(file)

config["cloaks"].each do |cloak|
  test_cloak(cloak["url"], cloak["name"], cloak["token"], cloak["tests"])
end

if not $errors.empty? then
  message = format_mail(config["email_to"])
  Net::SMTP.start(config["email_server"], config["email_port"]) do |smtp|
    smtp.send_message message, 'no-reply@aircloak.com', config["email_to"]
    puts "Notification email sent!"
  end
end
