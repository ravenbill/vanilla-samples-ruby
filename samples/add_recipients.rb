#!/usr/bin/env ruby
# Create an envelope, add recipients with different roles, and configure tabs.

require_relative "../lib/auth"

puts "=== Add Recipients and Tabs ==="

puts "\n1. Creating envelope..."
status, envelope = Vanilla::Auth.post("/envelopes", {
  envelope: {
    title: "Multi-Signer Contract",
    message: "Contract requiring multiple signers."
  }
})
raise "Create failed (#{status})" unless status == 201
envelope_id = envelope.dig("envelope", "id")
puts "   Envelope: #{envelope_id}"

recipients = [
  { name: "Alice Johnson", email: "alice@example.com", role: "signer", order: 1 },
  { name: "Bob Smith",     email: "bob@example.com",   role: "signer", order: 2 },
  { name: "Carol Williams", email: "carol@example.com", role: "cc" }
]

puts "\n2. Adding recipients..."
recipients.each do |r|
  status, result = Vanilla::Auth.post("/envelopes/#{envelope_id}/recipients", { recipient: r })
  raise "Add recipient failed for #{r[:email]} (#{status})" unless [200, 201].include?(status)

  recipient_id = result.dig("recipient", "id")
  puts "   Added #{r[:name]} (#{r[:role]}): #{recipient_id}"

  next unless r[:role] == "signer"

  puts "   Adding signature tab for #{r[:name]}..."
  tab_status, _tab = Vanilla::Auth.post(
    "/envelopes/#{envelope_id}/recipients/#{recipient_id}/tabs",
    {
      tab: {
        type: "signature",
        page: 1,
        x: 100,
        y: 500 + (r[:order].to_i * 80)
      }
    }
  )
  raise "Add tab failed (#{tab_status})" unless [200, 201].include?(tab_status)
  puts "   Signature tab placed."
end

puts "\n3. Retrieving envelope with recipients..."
status, full = Vanilla::Auth.get("/envelopes/#{envelope_id}")
recipient_count = full.dig("envelope", "recipients")&.length || "unknown"
puts "   Envelope has #{recipient_count} recipient(s)"

puts "\nDone."
