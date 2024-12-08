defmodule CryptoStream.Trading.Domain.TradingService do
  @moduledoc """
  Domain service for handling trading operations.
  This module contains the core business logic for trading operations.
  """

  alias CryptoStream.Trading.Domain.Transaction
  alias CryptoStream.Trading.Ports.TradingRepository
  alias Decimal, as: D

  @doc """
  Executes a buy operation for cryptocurrency.
  """
  def buy_cryptocurrency(account, cryptocurrency, amount_usd, price_usd) do
    with {:ok, account} <- TradingRepository.get_account(account),
         :ok <- validate_balance(account, amount_usd),
         attrs <- Transaction.new_buy(cryptocurrency, amount_usd, price_usd, account),
         {:ok, transaction} <- TradingRepository.create_transaction(attrs),
         new_balance = D.sub(account.balance_usd, amount_usd),
         {:ok, _updated_account} <- TradingRepository.update_account_balance(account, new_balance) do
      {:ok, transaction}
    else
      {:error, _reason} -> {:error, :insufficient_balance}
    end
  end

  @doc """
  Lists all transactions for a given account.
  """
  def list_account_transactions(account) do
    TradingRepository.list_account_transactions(account)
  end

  # Private functions

  defp validate_balance(account, amount_usd) do
    if D.compare(account.balance_usd, amount_usd) == :gt do
      :ok
    else
      {:error, :insufficient_balance}
    end
  end
end
