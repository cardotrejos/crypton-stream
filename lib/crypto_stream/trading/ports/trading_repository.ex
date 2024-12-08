defmodule CryptoStream.Trading.Ports.TradingRepository do
  @moduledoc """
  Port interface for trading persistence operations.
  This module defines the contract for the trading repository.
  """

  alias CryptoStream.Trading.Domain.Transaction
  alias CryptoStream.Accounts.Account
  alias CryptoStream.Repo
  alias Ecto.Multi

  @doc """
  Gets an account by ID.
  """
  @spec get_account(integer()) :: {:ok, Account.t()} | nil
  def get_account(account_id) do
    case Repo.get(Account, account_id) do
      nil -> nil
      account -> {:ok, account}
    end
  end

  @doc """
  Gets a transaction by ID.
  """
  @spec get_transaction!(integer()) :: Transaction.t() | no_return()
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Executes a buy transaction in a single database transaction.
  """
  @spec execute_buy_transaction(Ecto.Changeset.t(), Account.t()) :: 
    {:ok, %{transaction: Transaction.t(), account: Account.t()}} | {:error, atom()}
  def execute_buy_transaction(transaction_changeset, account) do
    new_balance = Decimal.sub(account.balance_usd, transaction_changeset.changes.total_usd)

    Multi.new()
    |> Multi.insert(:transaction, transaction_changeset)
    |> Multi.update(:update_balance, Account.changeset(account, %{balance_usd: new_balance}))
    |> Repo.transaction()
    |> case do
      {:ok, %{transaction: transaction, update_balance: updated_account}} ->
        {:ok, %{transaction: transaction, account: updated_account}}
      {:error, _failed_operation, reason, _changes} ->
        {:error, reason}
    end
  end

  @doc """
  Lists all transactions for an account ordered by insertion date.
  """
  @spec list_account_transactions(integer()) :: [Transaction.t()]
  def list_account_transactions(account_id) do
    import Ecto.Query

    Transaction
    |> where(account_id: ^account_id)
    |> order_by([t], [desc: t.inserted_at, desc: t.id])
    |> Repo.all()
  end
end
