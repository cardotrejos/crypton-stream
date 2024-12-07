defmodule CryptoStream.Services.CoingeckoBehaviour do
  @callback get_prices() :: {:ok, map()} | {:error, String.t()}
  @callback get_coin_info(String.t()) :: {:ok, map()} | {:error, String.t()}
  @callback get_historical_prices(String.t(), integer(), integer()) :: {:ok, map()} | {:error, String.t()}
  @callback supported_coin?(String.t()) :: boolean()
end
