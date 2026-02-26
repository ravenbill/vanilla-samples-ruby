#!/usr/bin/env ruby
# Create a draft envelope and send it.

require_relative "../lib/auth"

puts "=== Create and Send Envelope ==="

puts "\n1. Creating draft envelope..."
status, envelope = Vanilla::Auth.post("/envelopes", {
  envelope: {
    title: "Sample Agreement",
    message: "Please review and sign this document."
  }
})
raise "Create failed (#{status}): #{envelope}" unless status == 201

envelope_id = envelope.dig("envelope", "id")
puts "   Created envelope: #{envelope_id}"

puts "\n2. Adding a recipient..."
status, recipient = Vanilla::Auth.post("/envelopes/#{envelope_id}/recipients", {
  recipient: {
    name: "Jane Doe",
    email: "jane@example.com",
    role: "signer"
  }
})
raise "Add recipient failed (#{status}): #{recipient}" unless [200, 201].include?(status)
puts "   Added recipient: #{recipient.dig("recipient", "id")}"

puts "\n3. Sending the envelope..."
status, result = Vanilla::Auth.post("/envelopes/#{envelope_id}/send")
raise "Send failed (#{status}): #{result}" unless [200, 204].include?(status)
puts "   Envelope sent!"

puts "\n4. Verifying status..."
status, updated = Vanilla::Auth.get("/envelopes/#{envelope_id}")
puts "   Envelope state: #{updated.dig("envelope", "state")}"

puts "\nDone."
