defmodule CryptoStream.Services.CoingeckoClient do
  @moduledoc """
  Client for interacting with the Coingecko API to fetch cryptocurrency data.
  """

  @base_url "https://api.coingecko.com/api/v3"
  @supported_coins ["bitcoin", "solana"]

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
  def get_coin_info(coin_id) when coin_id in @supported_coins do
    case HTTPoison.get("#{@base_url}/coins/#{coin_id}?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Coingecko API returned status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch coin info: #{inspect(reason)}"}
    end
  end

  @doc """
  Fetches historical price data for a specific cryptocurrency.
  
  ## Parameters
    - coin_id: The ID of the cryptocurrency (e.g., "bitcoin" or "solana")
    - from_date: Start date in Unix timestamp
    - to_date: End date in Unix timestamp
  """
  def get_historical_prices(coin_id, from_date, to_date) when coin_id in @supported_coins do
    url = "#{@base_url}/coins/#{coin_id}/market_chart/range?vs_currency=usd&from=#{from_date}&to=#{to_date}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, "Coingecko API returned status code: #{status_code}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Failed to fetch historical prices: #{inspect(reason)}"}
    end
  end

  @doc """
  Validates if a coin is supported by our service.
  """
  def supported_coin?(coin_id), do: coin_id in @supported_coins
end
