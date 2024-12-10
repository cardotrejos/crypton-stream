Mox.defmock(CryptoStream.Services.MockCoingeckoClient, for: CryptoStream.Services.PriceClient)

defmodule CryptoStream.Services.MockCoingeckoClient do
  @behaviour CryptoStream.Services.PriceClient

  def get_price(cryptocurrency, _vs_currency) do
    case cryptocurrency do
      "bitcoin" -> {:ok, "50000.00"}
      _ -> {:error, :invalid_cryptocurrency}
    end
  end

  @impl true
  def get_prices do
    {:ok, %{
      "bitcoin" => %{"usd" => 50_000.00},
      "solana" => %{"usd" => 3_000.00}
    }}
  end

  @impl true
  def get_historical_prices(_coin_id, _from_date, _to_date) do
    {:ok, %{
      "prices" => [
        [1_639_123_200_000, 50_000.00],
        [1_639_209_600_000, 51_000.00]
      ]
    }}
  end

  @impl true
  def supported_coin?(coin_id) do
    coin_id in ["bitcoin", "solana"]
  end
end
