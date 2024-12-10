defmodule CryptoStream.Services.CoingeckoBehaviour do
  @callback get_price(String.t(), String.t()) :: {:ok, Decimal.t()} | {:error, atom()}
  @callback get_prices() :: {:ok, map()} | {:error, atom()}
  @callback get_historical_prices(String.t(), DateTime.t(), DateTime.t()) :: {:ok, list(map())} | {:error, atom()}
  @callback supported_coin?(String.t()) :: boolean()
end
