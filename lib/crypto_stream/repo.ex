defmodule CryptoStream.Repo do
  use Ecto.Repo,
    otp_app: :crypto_stream,
    adapter: Ecto.Adapters.Postgres
end
