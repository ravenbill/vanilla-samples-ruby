#!/usr/bin/env ruby
# Read a CSV of recipients and create+send an envelope for each.

require "csv"
require_relative "../lib/auth"

CSV_PATH = ARGV[0] || File.join(__dir__, "..", "data", "recipients.csv")

puts "=== Bulk Send ==="
puts "Reading recipients from: #{CSV_PATH}"

unless File.exist?(CSV_PATH)
  puts "File not found: #{CSV_PATH}"
  exit 1
end

rows = CSV.read(CSV_PATH, headers: true)
puts "Found #{rows.length} recipient(s)\n\n"

results = { success: 0, failed: 0 }

rows.each_with_index do |row, i|
  name  = row["name"]
  email = row["email"]
  role  = row["role"] || "signer"

  puts "#{i + 1}. Processing #{name} <#{email}> (#{role})..."

  begin
    status, envelope = Vanilla::Auth.post("/envelopes", {
      envelope: {
        title: "Agreement for #{name}",
        message: "Hi #{name}, please review and sign."
      }
    })
    raise "Create failed (#{status})" unless status == 201
    envelope_id = envelope.dig("envelope", "id")

    Vanilla::Auth.post("/envelopes/#{envelope_id}/recipients", {
      recipient: { name: name, email: email, role: role }
    })

    if role == "signer"
      Vanilla::Auth.post("/envelopes/#{envelope_id}/send")
      puts "   Sent envelope #{envelope_id}"
    else
      puts "   Created envelope #{envelope_id} (CC — not sent)"
    end

    results[:success] += 1
  rescue => e
    puts "   ERROR: #{e.message}"
    results[:failed] += 1
  end
end

puts "\n=== Summary ==="
puts "Successful: #{results[:success]}"
puts "Failed:     #{results[:failed]}"
puts "Done."
