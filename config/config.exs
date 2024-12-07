# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :crypto_stream,
  ecto_repos: [CryptoStream.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :crypto_stream, CryptoStreamWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: CryptoStreamWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: CryptoStream.PubSub,
  live_view: [signing_salt: "9r4i4ugQ"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :crypto_stream, CryptoStream.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Guardian
config :crypto_stream, CryptoStream.Guardian,
  issuer: "crypto_stream",
  secret_key: "jJ4GgaR7LldJV7eGborygPlJ9RvrFBFNaPndlTkg02epdpi0DhQ5kI8lOShPttCT" # Replace this with a secure secret key in production

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
