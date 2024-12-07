defmodule CryptoStream.Services.CoingeckoClient do
  @moduledoc """
  Client for interacting with the Coingecko API to fetch cryptocurrency data.
  """

  @base_url "https://api.coingecko.com/api/v3"

  @doc """
  Fetches current price data for Bitcoin and Solana in USD.
  """
  def get_prices do
    case HTTPoison.get("#{@base_url}/simple/price?ids=bitcoin,solana&vs_currencies=usd") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Coingecko API returned status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch prices: #{inspect(reason)}"}
    end
  end

  @doc """
  Fetches detailed information about a specific cryptocurrency.
  """
  def get_coin_info(coin_id) when coin_id in ["bitcoin", "solana"] do
    case HTTPoison.get("#{@base_url}/coins/#{coin_id}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Coingecko API returned status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch coin info: #{inspect(reason)}"}
    end
  end
end
