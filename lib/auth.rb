require "net/http"
require "json"
require "uri"
require_relative "config"

module Vanilla
  module Auth
    def self.sign_in
      uri = URI("#{API_URL}/api/auth/sign-in")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(email: EMAIL, password: PASSWORD)

      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise "Authentication failed (#{response.code}): #{response.body}"
      end

      data = JSON.parse(response.body)
      data.fetch("token")
    end

    def self.auth_headers
      token = sign_in
      {
        "Authorization" => "Bearer #{token}",
        "Content-Type"  => "application/json"
      }
    end

    # Convenience: make an authenticated GET request
    def self.get(path)
      uri = URI(api_path(path))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Get.new(uri)
      auth_headers.each { |k, v| request[k] = v }

      response = http.request(request)
      [response.code.to_i, JSON.parse(response.body)]
    end

    # Convenience: make an authenticated POST request
    def self.post(path, body = {})
      uri = URI(api_path(path))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri)
      auth_headers.each { |k, v| request[k] = v }
      request.body = JSON.generate(body)

      response = http.request(request)
      [response.code.to_i, JSON.parse(response.body)]
    end

    # Convenience: download binary content
    def self.download(path)
      uri = URI(api_path(path))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Get.new(uri)
      token = sign_in
      request["Authorization"] = "Bearer #{token}"

      http.request(request)
    end
  end
end
