defmodule CryptoStream.Services.CoingeckoClient do
  @moduledoc """
  Client for interacting with the CoinGecko API.
  """

  @behaviour CryptoStream.Services.PriceClient

  @supported_coins ["bitcoin", "solana"]

  @impl true
  def get_prices do
    base_url = Application.get_env(:crypto_stream, :coingecko_base_url, "https://api.coingecko.com/api/v3")
    api_key = Application.get_env(:crypto_stream, :coingecko_api_key)
    ids = Enum.join(@supported_coins, ",")
    url = "#{base_url}/simple/price?ids=#{ids}&vs_currencies=usd&x_cg_demo_api_key=#{api_key}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, data} -> {:ok, data}
          {:error, _} -> {:error, "Failed to parse response"}
        end

      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "API request failed with status #{status}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end

  @impl true
  def get_historical_prices(coin, from_date, to_date) do
    unless supported_coin?(coin) do
      {:error, "Unsupported cryptocurrency: #{coin}"}
    else
      base_url = Application.get_env(:crypto_stream, :coingecko_base_url, "https://api.coingecko.com/api/v3")
      api_key = Application.get_env(:crypto_stream, :coingecko_api_key)
      from_unix = DateTime.to_unix(from_date)
      to_unix = DateTime.to_unix(to_date)
      
      url = "#{base_url}/coins/#{coin}/market_chart/range?vs_currency=usd&from=#{from_unix}&to=#{to_unix}&x_cg_demo_api_key=#{api_key}"

      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          case Jason.decode(body) do
            {:ok, data} -> {:ok, data}
            {:error, _} -> {:error, "Failed to parse response"}
          end

        {:ok, %HTTPoison.Response{status_code: status}} ->
          {:error, "API request failed with status #{status}"}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTP request failed: #{reason}"}
      end
    end
  end

  @impl true
  def supported_coin?(coin), do: coin in @supported_coins
end
