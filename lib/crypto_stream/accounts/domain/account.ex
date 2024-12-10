defmodule CryptoStream.Accounts.Domain.Account do
  @moduledoc """
  Domain entity representing a user's trading account.
  This module encapsulates account-related business rules and validations.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias CryptoStream.Accounts.Domain.User
  alias CryptoStream.Trading.Domain.Transaction
  alias Decimal, as: D

  @type t :: %__MODULE__{
    balance_usd: Decimal.t(),
    user_id: integer(),
    user: User.t() | nil,
    transactions: [Transaction.t()] | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }

  @initial_balance D.new("100000.00")

  schema "accounts" do
    field :balance_usd, :decimal, default: @initial_balance
    belongs_to :user, User
    has_many :transactions, Transaction

    timestamps()
  end

  @doc """
  Creates a new account changeset.
  Enforces business rules:
  - Balance must be non-negative
  - Must be associated with a user
  """
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance_usd, :user_id])
    |> validate_required([:balance_usd, :user_id])
    |> validate_number(:balance_usd, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Creates a new account for a user with the default initial balance.
  """
  def new_account(user_id) when is_integer(user_id) do
    changeset(%__MODULE__{}, %{
      balance_usd: @initial_balance,
      user_id: user_id
    })
  end

  @doc """
  Checks if the account has sufficient balance for a transaction.
  """
  def has_sufficient_balance?(%__MODULE__{balance_usd: balance}, amount) do
    D.compare(balance, amount) != :lt
  end

  @doc """
  Updates the account balance by subtracting the given amount.
  Returns error if the resulting balance would be negative.
  """
  def update_balance(%__MODULE__{} = account, %Decimal{} = amount) do
    new_balance = D.sub(account.balance_usd, amount)

    if D.compare(new_balance, 0) == :lt do
      {:error, :insufficient_balance}
    else
      changeset(account, %{balance_usd: new_balance})
    end
  end

  @doc """
  Creates a new changeset for updating the account balance.
  """
  def balance_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance_usd])
    |> validate_required([:balance_usd])
    |> validate_number(:balance_usd, greater_than_or_equal_to: 0)
  end
end
