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
    field :amount_usd, :decimal
    field :total_usd, :decimal
    field :price_usd, :decimal
    field :account_id, :integer

    timestamps()
  end

  @doc """
  Creates a new transaction changeset.
  """
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :cryptocurrency, :amount_usd, :price_usd, :total_usd, :account_id])
    |> validate_required([:type, :cryptocurrency, :amount_usd, :price_usd, :total_usd, :account_id])
    |> validate_inclusion(:type, ["buy", "sell"])
    |> validate_number(:amount_usd, greater_than: 0)
    |> validate_number(:price_usd, greater_than: 0)
    |> validate_number(:total_usd, greater_than: 0)
    |> update_change(:amount_usd, &Decimal.round(&1, 8))
    |> update_change(:total_usd, &Decimal.round(&1, 8))
    |> update_change(:price_usd, &Decimal.round(&1, 8))
  end

  @doc """
  Creates a new buy transaction.
  """
  def new_buy(cryptocurrency, amount_usd, price_usd, account) when is_struct(account) do
    total_usd = Decimal.mult(amount_usd, price_usd)
    %{
      type: "buy",
      cryptocurrency: cryptocurrency,
      amount_usd: amount_usd,
      price_usd: price_usd,
      total_usd: total_usd,
      account_id: account.id
    }
  end
end
