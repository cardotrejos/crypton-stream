defmodule CryptoStream.Trading.Domain.TradingService do
  @moduledoc """
  Domain service for handling trading operations.
  This module contains the core business logic for trading operations.
  """

  alias CryptoStream.Trading.Domain.Transaction
  alias CryptoStream.Trading.Ports.TradingRepository
  alias Decimal, as: D

  @doc """
  Executes a buy operation for cryptocurrency using USD amount.
  """
  def buy_cryptocurrency_with_usd(account, cryptocurrency, amount_usd, price_usd) do
    with {:ok, account} <- TradingRepository.get_account(account),
         :ok <- validate_balance(account, amount_usd),
         crypto_amount = D.div(amount_usd, price_usd),
         attrs = %{
           type: "buy",
           cryptocurrency: cryptocurrency,
           amount_crypto: crypto_amount,
           amount_usd: amount_usd,
           price_usd: price_usd,
           account_id: account.id
         },
         {:ok, transaction} <- TradingRepository.create_transaction(attrs),
         new_balance = D.sub(account.balance_usd, amount_usd),
         {:ok, _updated_account} <- TradingRepository.update_account_balance(account, new_balance) do
      {:ok, transaction}
    else
      {:error, :insufficient_balance} = error -> error
      {:error, _reason} -> {:error, :transaction_failed}
    end
  end

  @doc """
  Executes a buy operation for cryptocurrency using crypto amount.
  """
  def buy_cryptocurrency_with_crypto(account, cryptocurrency, crypto_amount, price_usd) do
    amount_usd = D.mult(crypto_amount, price_usd)
    buy_cryptocurrency_with_usd(account, cryptocurrency, amount_usd, price_usd)
  end

  @doc """
  Lists all transactions for a given account.
  """
  def list_account_transactions(account) do
    TradingRepository.list_account_transactions(account)
  end

  # Private functions

  defp validate_balance(account, amount_usd) do
    if D.compare(account.balance_usd, amount_usd) in [:gt, :eq] do
      :ok
    else
      {:error, :insufficient_balance}
    end
  end
end
