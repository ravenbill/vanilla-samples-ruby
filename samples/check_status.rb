#!/usr/bin/env ruby
# Get envelope by ID, filter by state, and poll for completion.

require_relative "../lib/auth"

POLL_INTERVAL = 5
MAX_POLLS = 12

puts "=== Check Envelope Status ==="

envelope_id = ARGV[0]

if envelope_id
  puts "\n1. Getting envelope #{envelope_id}..."
  status, envelope = Vanilla::Auth.get("/envelopes/#{envelope_id}")
  raise "Get failed (#{status})" unless status == 200

  env = envelope["envelope"]
  puts "   Title: #{env["title"]}"
  puts "   State: #{env["state"]}"
  puts "   Created: #{env["created_at"]}"
  puts "   Updated: #{env["updated_at"]}"
else
  puts "\n   (Tip: pass an envelope ID as argument to check a specific one)"
end

puts "\n2. Filtering envelopes by state..."
%w[draft sent completed].each do |state|
  status, result = Vanilla::Auth.get("/envelopes?state=#{state}")
  next unless status == 200
  count = (result["envelopes"] || []).length
  puts "   #{state}: #{count} envelope(s)"
end

if envelope_id
  puts "\n3. Polling envelope until completed (max #{MAX_POLLS * POLL_INTERVAL}s)..."
  MAX_POLLS.times do |i|
    status, envelope = Vanilla::Auth.get("/envelopes/#{envelope_id}")
    state = envelope.dig("envelope", "state")
    puts "   Poll #{i + 1}: state=#{state}"

    if state == "completed"
      puts "   Envelope completed!"
      break
    end

    sleep POLL_INTERVAL
  end
end

puts "\nDone."
