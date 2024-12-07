defmodule CryptoStream.Services.PriceClient do
  @moduledoc """
  Behaviour for cryptocurrency price data clients.
  """

  @callback get_prices() :: {:ok, map()} | {:error, String.t()}
  @callback get_historical_prices(String.t(), DateTime.t(), DateTime.t()) :: {:ok, map()} | {:error, String.t()}
  @callback supported_coin?(String.t()) :: boolean()
end
