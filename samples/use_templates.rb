#!/usr/bin/env ruby
# List available templates and create an envelope from a template.

require_relative "../lib/auth"

puts "=== Use Templates ==="

puts "\n1. Listing templates..."
status, result = Vanilla::Auth.get("/templates")
raise "List templates failed (#{status})" unless status == 200

templates = result["templates"] || []
if templates.empty?
  puts "   No templates found. Create one in the UI first."
  puts "   Skipping envelope creation."
  exit 0
end

templates.each do |t|
  puts "   [#{t["id"]}] #{t["name"]} — #{t["description"] || "no description"}"
end

template = templates.first
puts "\n2. Creating envelope from template '#{template["name"]}'..."
status, envelope = Vanilla::Auth.post("/envelopes", {
  envelope: {
    template_id: template["id"],
    title: "From Template: #{template["name"]}",
    message: "Created from a template."
  }
})
raise "Create from template failed (#{status})" unless status == 201

envelope_id = envelope.dig("envelope", "id")
puts "   Created envelope: #{envelope_id}"

puts "\n3. Reviewing pre-filled recipients..."
status, detail = Vanilla::Auth.get("/envelopes/#{envelope_id}")
recipients = detail.dig("envelope", "recipients") || []
recipients.each do |r|
  puts "   #{r["name"]} <#{r["email"]}> — #{r["role"]}"
end

puts "\nDone. Customize recipients and send when ready."
