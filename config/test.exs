import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :crypto_stream, CryptoStream.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5433,
  database: "crypto_stream_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2,
  template: "template0",
  encoding: "UTF8",
  lc_collate: "en_US.UTF-8",
  lc_ctype: "en_US.UTF-8"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :crypto_stream, CryptoStreamWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "D1S29g0ujdC2L6YtNawrpg+Y2j8kOl3IqTzuKzXfSKN+dTzhHpGPbCtfRJZLg7iz",
  server: false

# In test we don't send emails
config :crypto_stream, CryptoStream.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Configure test environment to use mock client
config :crypto_stream,
  coingecko_client: CryptoStream.Services.MockCoingeckoClient

config :crypto_stream, CryptoStreamWeb.Guardian,
  issuer: "crypto_stream",
  secret_key: "test_secret_key_for_testing_only"

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
