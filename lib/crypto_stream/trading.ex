defmodule CryptoStream.Trading do
  import Ecto.Query
  alias CryptoStream.Repo
  alias CryptoStream.Trading.Transaction
  alias CryptoStream.Accounts.Account
  alias Ecto.Multi

  @doc """
  Simulates buying cryptocurrency with the user's virtual USD balance.
  Returns {:ok, %{transaction: transaction, account: updated_account}} on success,
  or {:error, reason} on failure.
  """
  def buy_cryptocurrency(account_id, cryptocurrency, amount_crypto, price_usd) do
    with {:ok, amount} <- parse_decimal(amount_crypto),
         {:ok, price} <- parse_decimal(price_usd),
         {:ok, total_cost} <- multiply_decimals(amount, price) do
      Multi.new()
      |> Multi.run(:account, fn repo, _changes ->
        case repo.get(Account, account_id) do
          nil -> {:error, :account_not_found}
          account ->
            case Decimal.compare(account.balance_usd, total_cost) do
              :lt -> {:error, :insufficient_balance}
              _ -> {:ok, account}
            end
        end
      end)
      |> Multi.insert(:transaction, fn %{account: account} ->
        Transaction.changeset(%Transaction{}, %{
          type: :buy,
          cryptocurrency: cryptocurrency,
          amount_crypto: amount,
          price_usd: price,
          total_usd: total_cost,
          account_id: account.id
        })
      end)
      |> Multi.update(:update_balance, fn %{account: account} ->
        new_balance = Decimal.sub(account.balance_usd, total_cost)
        Account.changeset(account, %{balance_usd: new_balance})
      end)
      |> Repo.transaction()
      |> case do
        {:ok, %{transaction: transaction, update_balance: account}} ->
          {:ok, %{transaction: transaction, account: account}}
        {:error, _failed_operation, reason, _changes} ->
          {:error, reason}
      end
    else
      {:error, :invalid_decimal} ->
        {:error, :invalid_decimal}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gets a transaction by ID
  """
  def get_transaction!(id), do: Repo.get!(Transaction, id)

  @doc """
  Lists all transactions for an account
  """
  def list_account_transactions(account_id) do
    Transaction
    |> where(account_id: ^account_id)
    |> order_by([t], [desc: t.inserted_at, desc: t.id])
    |> Repo.all()
  end

  # Private functions

  defp parse_decimal(value) when is_binary(value) do
    case Decimal.parse(value) do
      {decimal, ""} -> {:ok, decimal}
      _ -> {:error, :invalid_decimal}
    end
  rescue
    _ -> {:error, :invalid_decimal}
  end

  defp parse_decimal(value) when is_number(value) do
    {:ok, Decimal.new(value)}
  end

  defp parse_decimal(_), do: {:error, :invalid_decimal}

  defp multiply_decimals(a, b) do
    {:ok, Decimal.mult(a, b)}
  rescue
    _ -> {:error, :decimal_error}
  end
end
