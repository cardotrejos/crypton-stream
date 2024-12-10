defmodule CryptoStream.Trading do
  @moduledoc """
  The Trading context.
  This module serves as the public API for trading operations,
  delegating to the domain layer for business logic.
  """

  alias CryptoStream.Trading.Domain.TradingService

  @doc """
  Buy cryptocurrency with USD amount.
  Returns {:ok, transaction} on success, or {:error, reason} on failure.
  """
  defdelegate buy_cryptocurrency_with_usd(account_id, cryptocurrency, amount_usd, price_usd),
    to: TradingService

  @doc """
  Buy cryptocurrency with crypto amount.
  Returns {:ok, transaction} on success, or {:error, reason} on failure.
  """
  defdelegate buy_cryptocurrency_with_crypto(account_id, cryptocurrency, amount_crypto, price_usd),
    to: TradingService

  @doc """
  Lists all transactions for an account
  """
  defdelegate list_account_transactions(account_id),
    to: TradingService

  @doc """
  Gets a transaction by ID
  """
  def get_transaction!(id) do
    CryptoStream.Trading.Ports.TradingRepository.get_transaction!(id)
  end
end
