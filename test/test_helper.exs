ExUnit.start()
Mox.defmock(CryptoStream.Services.MockCoingeckoClient, for: CryptoStream.Services.CoingeckoBehaviour)
Application.put_env(:crypto_stream, :coingecko_client, CryptoStream.Services.MockCoingeckoClient)
Ecto.Adapters.SQL.Sandbox.mode(CryptoStream.Repo, :manual)
