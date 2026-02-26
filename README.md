# Vanilla API — Ruby Samples

Runnable code samples for the Vanilla API using **only Ruby stdlib** (no gems required).

## Prerequisites

- Ruby 3.0+

## Setup

```bash
git clone <repo-url> && cd vanilla-samples-ruby
```

Set the required environment variables:

```bash
export VANILLA_API_URL="https://your-instance.example.com"  # default: http://localhost:4000
export VANILLA_EMAIL="you@example.com"
export VANILLA_PASSWORD="your-password"
export VANILLA_ACCOUNT_ID="your-account-id"
```

## Running Samples

```bash
ruby samples/create_and_send_envelope.rb
ruby samples/add_recipients.rb
ruby samples/use_templates.rb
ruby samples/check_status.rb
ruby samples/download_documents.rb
ruby samples/webhook_handler.rb
ruby samples/bulk_send.rb
ruby samples/graphql_queries.rb
```

## Sample Descriptions

| Sample | Description |
|--------|-------------|
| `create_and_send_envelope.rb` | Create a draft envelope and send it |
| `add_recipients.rb` | Create an envelope, add recipients, and configure tabs |
| `use_templates.rb` | List available templates and create an envelope from one |
| `check_status.rb` | Get envelope by ID, filter by state, poll for completion |
| `download_documents.rb` | Download the signed PDF and signing certificate |
| `webhook_handler.rb` | WEBrick server that receives and verifies webhook events |
| `bulk_send.rb` | Read a CSV file and create+send an envelope per recipient |
| `graphql_queries.rb` | Execute GraphQL queries and mutations |

## License

MIT — Copyright 2026 Ravenbill
