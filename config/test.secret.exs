import Config

config :crypto_stream, CryptoStreamWeb.Auth.Guardian,
  issuer: "crypto_stream",
  secret_key: "test_secret_key_for_testing_only_do_not_use_in_production"
