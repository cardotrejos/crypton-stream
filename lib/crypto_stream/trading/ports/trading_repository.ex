defmodule CryptoStream.Trading.Ports.TradingRepository do
  @moduledoc """
  Port interface for trading persistence operations.
  This module defines the contract for the trading repository.
  """

  import Ecto.Query

  alias CryptoStream.Repo
  alias CryptoStream.Trading.Domain.Transaction
  alias CryptoStream.Accounts.Domain.Account
  alias Ecto.Multi

  @doc """
  Gets an account by ID or returns the account if it's already a struct.
  """
  def get_account(%Account{} = account), do: {:ok, Repo.get!(Account, account.id)}
  def get_account(account_id) when is_integer(account_id), do: {:ok, Repo.get!(Account, account_id)}

  @doc """
  Gets a transaction by ID.
  """
  @spec get_transaction!(integer()) :: Transaction.t() | no_return()
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Executes a buy transaction in a single database transaction.
  """
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
  Updates an account balance.
  """
  def update_account_balance(%Account{} = account, new_balance) do
    account
    |> Account.balance_changeset(%{balance_usd: new_balance})
    |> Repo.update()
  end

  @doc """
  Creates a transaction.
  """
  def create_transaction(attrs) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all transactions for an account ordered by insertion date.
  """
  def list_account_transactions(%Account{} = account) do
    Repo.all(from t in Transaction, where: t.account_id == ^account.id)
  end
  def list_account_transactions(account_id) when is_integer(account_id) do
    import Ecto.Query

    Transaction
    |> where(account_id: ^account_id)
    |> order_by([t], [desc: t.inserted_at, desc: t.id])
    |> Repo.all()
  end
end
