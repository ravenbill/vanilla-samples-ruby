#!/usr/bin/env ruby
# Simple WEBrick server that receives and verifies Vanilla webhook events.

require "webrick"
require "json"
require "openssl"

WEBHOOK_SECRET = ENV.fetch("VANILLA_WEBHOOK_SECRET") { raise "Set VANILLA_WEBHOOK_SECRET env var" }
PORT = Integer(ENV.fetch("PORT", "8080"))

def verify_signature(payload, signature)
  expected = OpenSSL::HMAC.hexdigest("SHA256", WEBHOOK_SECRET, payload)
  Rack::Utils.secure_compare(expected, signature) if defined?(Rack)
  expected == signature
end

server = WEBrick::HTTPServer.new(Port: PORT, Logger: WEBrick::Log.new($stdout, WEBrick::Log::INFO))

server.mount_proc "/webhooks/vanilla" do |req, res|
  unless req.request_method == "POST"
    res.status = 405
    res.body = '{"error":"Method not allowed"}'
    next
  end

  payload = req.body
  signature = req.header["x-vanilla-signature"]&.first

  unless signature && verify_signature(payload, signature)
    puts "[WARN] Invalid or missing signature"
    res.status = 401
    res.body = '{"error":"Invalid signature"}'
    next
  end

  event = JSON.parse(payload)
  event_type = event["type"]
  event_id = event["id"]

  puts "[EVENT] #{event_type} (#{event_id})"

  case event_type
  when "envelope.sent"
    puts "  Envelope sent: #{event.dig("data", "envelope_id")}"
  when "envelope.completed"
    puts "  Envelope completed: #{event.dig("data", "envelope_id")}"
  when "recipient.signed"
    puts "  Recipient signed: #{event.dig("data", "recipient_id")} on #{event.dig("data", "envelope_id")}"
  when "envelope.voided"
    puts "  Envelope voided: #{event.dig("data", "envelope_id")}"
  else
    puts "  Unhandled event type: #{event_type}"
  end

  res.status = 200
  res["Content-Type"] = "application/json"
  res.body = '{"received":true}'
end

trap("INT") { server.shutdown }

puts "Webhook handler listening on http://localhost:#{PORT}/webhooks/vanilla"
puts "Press Ctrl+C to stop.\n\n"
server.start
