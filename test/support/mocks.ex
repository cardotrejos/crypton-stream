Mox.defmock(CryptoStream.Services.MockCoingeckoClient, for: CryptoStream.Services.CoingeckoBehaviour)

defmodule CryptoStream.Services.MockCoingeckoClient do
  @behaviour CryptoStream.Services.CoingeckoBehaviour

  def get_price(cryptocurrency, vs_currency) do
    case cryptocurrency do
      "bitcoin" -> {:ok, Decimal.new("50000.00")}
      _ -> {:error, :invalid_cryptocurrency}
    end
  end

  def get_prices do
    {:ok, %{
      "bitcoin" => %{"usd" => 50_000.00},
      "ethereum" => %{"usd" => 3_000.00}
    }}
  end

  def get_historical_prices(coin_id, from_date, to_date) do
    case coin_id do
      "bitcoin" -> {:ok, [
        %{
          "date" => "2024-01-01",
          "price" => 50_000.00
        },
        %{
          "date" => "2024-01-02",
          "price" => 51_000.00
        }
      ]}
      _ -> {:error, :invalid_cryptocurrency}
    end
  end

  def supported_coin?(coin_id) do
    coin_id == "bitcoin"
  end
end
