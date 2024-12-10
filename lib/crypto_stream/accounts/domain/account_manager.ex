defmodule CryptoStream.Accounts.Domain.AccountManager do
  @moduledoc """
  Domain module responsible for account management operations.
  """

  alias CryptoStream.Accounts.Domain.{User, Account}
  alias CryptoStream.Repo
  alias Decimal, as: D

  @type account_result :: {:ok, Account.t()} | {:error, Ecto.Changeset.t() | :not_found}
  @type balance_update_result :: {:ok, Account.t()} | {:error, :insufficient_funds | Ecto.Changeset.t()}

  @initial_balance D.new("100000.00")

  @spec create_account(User.t()) :: account_result
  def create_account(%User{} = user) do
    %Account{}
    |> Account.changeset(%{
      balance_usd: @initial_balance,
      user_id: user.id
    })
    |> Repo.insert()
  end

  @spec get_account(integer()) :: account_result
  def get_account(id) when is_integer(id) do
    case Repo.get(Account, id) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @spec update_balance(Account.t(), Decimal.t()) :: balance_update_result
  def update_balance(%Account{} = account, %Decimal{} = new_balance) do
    if D.lt?(new_balance, D.new(0)) do
      {:error, :insufficient_funds}
    else
      account
      |> Account.balance_changeset(%{balance_usd: new_balance})
      |> Repo.update()
    end
  end

  @spec get_account_by_user(User.t()) :: account_result
  def get_account_by_user(%User{} = user) do
    case Repo.preload(user, :account).account do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end
end
