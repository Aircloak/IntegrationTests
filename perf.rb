#!/usr/bin/env ruby

# Performance regression test

require "rubygems"
require "json"
require 'rest_client'
require 'net/smtp'
require 'date'

$warnings = []

def store_warning(url, datasource, test, warning)
  cell_style = 'style="border: 1px solid lightgrey"'
  message = <<ENDOFMESSAGE
  <tr><td #{cell_style}>Warning</td><td #{cell_style}>#{warning}</td></tr>
  <tr><td #{cell_style}>Target</td><td #{cell_style}>[#{url}]: #{datasource}</td></tr>
  <tr><td #{cell_style}>Query</td><td #{cell_style}>#{test["query"]}</td></tr>
ENDOFMESSAGE
  $warnings.push(message)
end

def format_mail(from, to)
  message = <<ENDOFMESSAGE
From: <#{from}>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: Performance regression detected :(

<table style="border-collapse: collapse;" cellpadding="4" width="100%">
#{$warnings.join("<tr><td colspan='2'>&nbsp;</td></tr>")}
</table>
<br/><hr/>
https://github.com/Aircloak/IntegrationTests/blob/master/README.md
ENDOFMESSAGE
end

def array_avg(arr) (arr.reduce(:+).to_f() / arr.count).round() end

def check_test(logs, url, test)
  test["datasources"].each do |datasource|
    check_test_on_datasource(logs, url, datasource, test)
  end
end

def check_test_on_datasource(logs, url, datasource, test)
  target = "#{datasource} [#{url}]"
  pattern = /^.+'#{Regexp.quote(test["query"])}'.+'#{Regexp.quote(target)}' \.+ completed in ([\d]+) seconds.$/
  durations = logs.map do |log| # extract test duration from logs
    if pattern =~ log then $1.to_i() else nil end
  end
  durations = durations.compact() # drop invalid values

  return if durations.count < 7 # skip tests that don't have enough successful passes

  last_avg = array_avg(durations.take(3)) # compute the average of the last 3 days
  prev_avg = array_avg(durations.drop(3)) # compute the average before the last 3 days

  return if last_avg < 60 # skip if test took less than 1 minute

  rel_diff = 100 * last_avg / prev_avg - 100
  puts "Duration for query '#{test["query"]}' on '#{datasource}' differs by #{rel_diff}%."
  if rel_diff >= 5 then # notify if the average duration increased by more than 5%
    abs_diff = last_avg - prev_avg
    store_warning(url, datasource, test, "Query duration increased " \
      "from #{prev_avg} seconds to #{last_avg} seconds (#{abs_diff} seconds or #{rel_diff}% more)")
  end
end


# -----------------------------------
# MAIN
# -----------------------------------

$stdout.sync = true # do not buffer output

config_file = if ARGV.length == 0 then 'config.json' else ARGV[0] end

time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
puts "Performance regression tests started at #{time}, using settings from '#{config_file}'."

file = File.read(config_file)
config = JSON.parse(file)

logs = Dir["logs/*.log"].sort().last(10).reverse()
logs = logs.map do |log| File.new(log).read end

config["cloaks"].each do |cloak|
  cloak["tests"].each do |tests_name|
    tests = config["tests"][tests_name]
    tests.each do |test|
      check_test(logs, cloak["url"], test)
    end
  end
end

# Because of the rampant fluctuations in performance on the NYC Taxi database
# dataset, that we are unable to explain, we disable the performance degradation
# emails for now.
#
# Just disabling doesn't solve any problems, so this should be accompanied by
# a subsequent task of pushing the data to elastic so we have easily browsable
# historic results.

# if not $warnings.empty? then
#   message = format_mail(config["email_from"], config["email_to"])
#   Net::SMTP.start(config["email_server"], config["email_port"]) do |smtp|
#     smtp.send_message message, config["email_from"], config["email_to"]
#     puts "Notification email sent!"
#   end
# end
