defmodule CryptoStream.Trading.Domain.TradingService do
  @moduledoc """
  Domain service for handling trading operations.
  This module contains the core business logic for trading operations.
  """

  alias CryptoStream.Trading.Domain.Transaction
  alias CryptoStream.Trading.Ports.TradingRepository
  alias CryptoStream.Accounts.Account
  alias Decimal, as: D

  @type trading_result :: {:ok, %{transaction: Transaction.t(), account: Account.t()}} | {:error, atom()}

  @doc """
  Executes a buy operation for cryptocurrency.
  """
  @spec buy_cryptocurrency(integer(), String.t(), String.t(), String.t(), module()) :: trading_result
  def buy_cryptocurrency(account_id, cryptocurrency, amount_crypto, price_usd, repo \\ TradingRepository) do
    case repo.get_account(account_id) do
      nil -> 
        {:error, :account_not_found}
      {:ok, account} ->
        with %Ecto.Changeset{valid?: true} = changeset <- Transaction.new_buy(cryptocurrency, amount_crypto, price_usd, account_id),
             :ok <- validate_sufficient_balance(account.balance_usd, changeset.changes.total_usd),
             {:ok, result} <- repo.execute_buy_transaction(changeset, account) do
          {:ok, result}
        else
          %Ecto.Changeset{valid?: false} = changeset -> {:error, changeset}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  @doc """
  Lists all transactions for a given account.
  """
  @spec list_account_transactions(integer(), module()) :: [Transaction.t()]
  def list_account_transactions(account_id, repo \\ TradingRepository) do
    repo.list_account_transactions(account_id)
  end

  # Private functions

  defp validate_sufficient_balance(balance, required_amount) do
    case D.compare(balance, required_amount) do
      :lt -> {:error, :insufficient_balance}
      _ -> :ok
    end
  end
end
