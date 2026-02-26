#!/usr/bin/env ruby
# Download the signed PDF and signing certificate for an envelope.

require_relative "../lib/auth"

puts "=== Download Documents ==="

envelope_id = ARGV[0]
unless envelope_id
  puts "Usage: ruby samples/download_documents.rb <envelope_id>"
  exit 1
end

puts "\n1. Getting envelope details..."
status, envelope = Vanilla::Auth.get("/envelopes/#{envelope_id}")
raise "Get failed (#{status})" unless status == 200

env = envelope["envelope"]
puts "   Title: #{env["title"]}"
puts "   State: #{env["state"]}"

documents = env["documents"] || []
if documents.empty?
  puts "   No documents found on this envelope."
  exit 0
end

puts "\n2. Downloading signed documents..."
documents.each do |doc|
  doc_id = doc["id"]
  filename = "#{doc["name"] || "document_#{doc_id}"}.pdf"

  response = Vanilla::Auth.download("/envelopes/#{envelope_id}/documents/#{doc_id}/download")
  unless response.is_a?(Net::HTTPSuccess)
    puts "   Failed to download #{filename} (#{response.code})"
    next
  end

  File.binwrite(filename, response.body)
  puts "   Saved: #{filename} (#{response.body.bytesize} bytes)"
end

puts "\n3. Downloading signing certificate..."
response = Vanilla::Auth.download("/envelopes/#{envelope_id}/certificate")
if response.is_a?(Net::HTTPSuccess)
  cert_file = "certificate_#{envelope_id}.pdf"
  File.binwrite(cert_file, response.body)
  puts "   Saved: #{cert_file} (#{response.body.bytesize} bytes)"
else
  puts "   Certificate not available (#{response.code})"
end

puts "\nDone."
