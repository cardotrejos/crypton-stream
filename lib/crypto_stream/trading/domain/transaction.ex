defmodule CryptoStream.Trading.Domain.Transaction do
  @moduledoc """
  Domain entity representing a cryptocurrency trading transaction.
  This is the core domain entity that encapsulates the business rules
  for cryptocurrency transactions.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
    type: String.t(),
    cryptocurrency: String.t(),
    amount_crypto: Decimal.t(),
    amount_usd: Decimal.t(),
    price_usd: Decimal.t(),
    total_usd: Decimal.t(),
    account_id: integer(),
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }

  schema "transactions" do
    field :type, :string
    field :cryptocurrency, :string
    field :amount_crypto, :decimal
    field :amount_usd, :decimal
    field :price_usd, :decimal
    field :total_usd, :decimal
    belongs_to :account, CryptoStream.Accounts.Domain.Account

    timestamps()
  end

  @required_fields [:type, :cryptocurrency, :amount_crypto, :price_usd, :total_usd, :account_id]
  @optional_fields [:amount_usd]

  @doc """
  Creates a new transaction changeset.
  """
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, ["buy", "sell"])
    |> validate_number(:amount_crypto, greater_than: 0)
    |> validate_number(:price_usd, greater_than: 0)
    |> validate_number(:total_usd, greater_than: 0)
    |> foreign_key_constraint(:account_id)
    |> update_change(:amount_crypto, &Decimal.round(&1, 8))
    |> update_change(:amount_usd, &Decimal.round(&1, 8))
    |> update_change(:total_usd, &Decimal.round(&1, 8))
    |> update_change(:price_usd, &Decimal.round(&1, 8))
  end

  @doc """
  Creates a new buy transaction.
  """
  def new_buy(cryptocurrency, amount_crypto, amount_usd, price_usd, account) when is_struct(account) do
    %{
      type: "buy",
      cryptocurrency: cryptocurrency,
      amount_crypto: amount_crypto,
      amount_usd: amount_usd,
      price_usd: price_usd,
      account_id: account.id
    }
  end
end
