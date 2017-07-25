#!/usr/bin/env ruby

require '../common/query_runner.rb'
require 'json'
require 'cgi'
require 'net/smtp'


# -------------------------------------------------------------------
# Backend system tests
# Runs the same set of queries across a set of supported backends,
# ensuring the result is identical across them all.
# -------------------------------------------------------------------

def check_query(query, air, api_token, datasources)
  partitions = query_datasources(air, api_token, datasources, query, 30)
    .group_by {|result| result["rows"]}
  if partitions.length == 1 then
    {success: true}
  else
    partitions = partitions.map do |result, values|
      {
        result: result,
        datasources: values.map {|value| value["datasource"]}
      }
    end
    {
      success: false,
      partitions: partitions
    }
  end
end


# -------------------------------------------------------------------
# Mail formatting and sending
# -------------------------------------------------------------------

def format_error(error)
  cell_style = 'style="border: 1px solid lightgrey"'
  message = <<ENDOFMESSAGE
  <tr>
    <td #{cell_style}>Query</td>
    <td #{cell_style}>
      <a href="https://github.com/Aircloak/IntegrationTests/blob/master/compliance/#{error[:path_segment]}">
        #{error[:name]}
      </a>
    </td>
  </tr>
ENDOFMESSAGE


  error[:partitions].each_with_index do |partition, i|
    message += <<ENDOFMESSAGE
<tr><td #{cell_style}>Partition #{i+1}</td><td #{cell_style}>#{partition[:datasources]}</td></tr>
<tr><td #{cell_style}>Result</td><td #{cell_style}>#{partition[:result]}</td></tr>
ENDOFMESSAGE
  end

  message
end

def format_mail(from, to, errors)
  <<ENDOFMESSAGE
From: <#{from}>
To: <#{to}>
MIME-Version: 1.0
Content-type: text/html
Subject: Compliance tests failed :(

<table style="border-collapse: collapse;" cellpadding="4" width="100%">
#{errors.map{|error| format_error(error)}.join("<tr><td colspan='2'>&nbsp;</td></tr>")}
</table>
<br/><hr/>
https://github.com/Aircloak/IntegrationTests/blob/master/README.md
ENDOFMESSAGE
end


# -------------------------------------------------------------------
# Main
# -------------------------------------------------------------------

$stdout.sync = true # do not buffer output

root_path = File.dirname(__FILE__)
config_file = if ARGV.length == 0 then "#{root_path}/config.json" else ARGV[0] end

time = Time.now.strftime("%Y/%m/%d %H:%M:%S")
puts("Compliance tests started at #{time}, using settings from '#{config_file}'.")

file = File.read(config_file)
config = JSON.parse(file)

air = config["air"]["url"]
api_token = config["air"]["token"]
datasources = config["datasources"]

errors = []

Dir["#{root_path}/queries/*.sql"].each do |query_file_path|
  query = File.read(query_file_path)
  result = check_query(query, air, api_token, datasources)
  unless result[:success] then
    errors << {
      query: query,
      partitions: result[:partitions],
      name: query_file_path.split("/").last,
      path_segment: query_file_path[1...query_file_path.length]
    }
  end
end

errors.each do |error|
  puts error[:query]
  puts "Query failed (produced #{error[:partitions].length} different results):"
  error[:partitions].each_with_index do |partition, i|
    puts "Partition #{i + 1}:\nData sources: #{partition[:datasources]}\nResult: #{partition[:result]}\n\n"
  end
  puts ""
end

if not errors.empty? then
  message = format_mail(config["email_from"], config["email_to"], errors)
  Net::SMTP.start(config["email_server"], config["email_port"]) do |smtp|
    smtp.send_message message, config["email_from"], config["email_to"]
    puts("Notification email sent!")
  end
end
