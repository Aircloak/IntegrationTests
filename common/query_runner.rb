# Shared functionality for running queries

require 'rest_client'
require "json"

def start_query(url, api_token, datasource, statement)
  body = {
    query: {
      statement: statement,
      data_source_name: datasource
    }
  }.to_json
  request = {
    method: :post,
    url: "https://#{url}/api/queries",
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
    url: "https://#{url}/api/queries/#{query_id}",
    headers: {
      'auth-token' => api_token
    }
  }
  response = RestClient::Request.execute(request)
  query = JSON.parse response.body
  query = query["query"]
end

def execute_query(url, api_token, datasources, statement, timeout)
  start_time = Time.now
  print "."

  query_ids = []
  datasources.each do |datasource|
    query = start_query(url, api_token, datasource, statement)
    if !query["success"] then raise "Failed to start query" end
    query_ids << {
      datasource: datasource,
      id: query["query_id"]
    }
  end

  completed_queries = []

  poll_interval = [(timeout / 100).round(), 2].max()
  progress = duration = 0
  begin
    sleep poll_interval
    progress += 1
    if progress % 5 == 0 then print "." end

    query_ids.delete_if do |query|
      response = get_query(url, api_token, query[:id]) # get current state
      if response["completed"] then
        completed_queries << {
          "rows" => response["rows"],
          "datasource" => query[:datasource]
        }
        true
      else
        false
      end
    end

    duration = (Time.now - start_time).round()
  end until query_ids == [] or duration > timeout

  if duration > timeout then raise "Query timeout (duration exceeded #{timeout} seconds)" end
  if completed_queries.any?{|query| query["error"]} then raise query["error"] end
  # Note: This log line is used by the perf.rb script to extract timing information.
  # If you modify it, you must update the parsing code in that file also.
  puts(" completed in #{duration} seconds.")

  completed_queries.map do |query|
    query["rows"] = query["rows"].map do |row|
      row["row"].map do |value|
        if value.is_a?(Float) then
          (value * 1000).round() / 1000.0 # keep 3 decimals at most (just like the UI)
        else
          value
        end
      end
    end
    query
  end
end
