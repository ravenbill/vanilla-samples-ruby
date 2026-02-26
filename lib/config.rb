module Vanilla
  API_URL    = ENV.fetch("VANILLA_API_URL", "http://localhost:4000")
  EMAIL      = ENV.fetch("VANILLA_EMAIL")    { raise "Set VANILLA_EMAIL env var" }
  PASSWORD   = ENV.fetch("VANILLA_PASSWORD") { raise "Set VANILLA_PASSWORD env var" }
  ACCOUNT_ID = ENV.fetch("VANILLA_ACCOUNT_ID") { raise "Set VANILLA_ACCOUNT_ID env var" }

  def self.api_path(path)
    "#{API_URL}/api/accounts/#{ACCOUNT_ID}#{path}"
  end
end
