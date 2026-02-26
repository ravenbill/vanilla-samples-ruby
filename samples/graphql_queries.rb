#!/usr/bin/env ruby
# Execute GraphQL queries and mutations against the Vanilla API.

require "net/http"
require "json"
require "uri"
require_relative "../lib/auth"

def graphql(query, variables = {})
  uri = URI("#{Vanilla::API_URL}/api/graphql")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"

  headers = Vanilla::Auth.auth_headers
  request = Net::HTTP::Post.new(uri)
  headers.each { |k, v| request[k] = v }
  request.body = JSON.generate(query: query, variables: variables)

  response = http.request(request)
  data = JSON.parse(response.body)

  if data["errors"]
    puts "GraphQL errors:"
    data["errors"].each { |e| puts "  - #{e["message"]}" }
  end

  data["data"]
end

puts "=== GraphQL Queries ==="

puts "\n1. List envelopes..."
data = graphql(<<~GQL)
  query {
    envelopes(first: 5) {
      nodes {
        id
        title
        state
        createdAt
      }
      totalCount
    }
  }
GQL

if data
  total = data.dig("envelopes", "totalCount") || 0
  puts "   Total envelopes: #{total}"
  (data.dig("envelopes", "nodes") || []).each do |e|
    puts "   [#{e["id"]}] #{e["title"]} — #{e["state"]}"
  end
end

puts "\n2. Get account info..."
data = graphql(<<~GQL)
  query {
    account {
      id
      name
      plan
      envelopeCount
    }
  }
GQL

if data && data["account"]
  acct = data["account"]
  puts "   Account: #{acct["name"]} (#{acct["plan"]})"
  puts "   Envelopes: #{acct["envelopeCount"]}"
end

puts "\n3. Create envelope via mutation..."
data = graphql(<<~GQL, { input: { title: "GraphQL Envelope", message: "Created via GraphQL" } })
  mutation CreateEnvelope($input: CreateEnvelopeInput!) {
    createEnvelope(input: $input) {
      envelope {
        id
        title
        state
      }
      errors
    }
  }
GQL

if data && data["createEnvelope"]
  result = data["createEnvelope"]
  if result["envelope"]
    puts "   Created: #{result["envelope"]["id"]} — #{result["envelope"]["title"]}"
  end
  (result["errors"] || []).each { |e| puts "   Error: #{e}" }
end

puts "\nDone."
