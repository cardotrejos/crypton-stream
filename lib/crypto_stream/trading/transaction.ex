defmodule CryptoStream.Trading.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :type, Ecto.Enum, values: [:buy, :sell]
    field :cryptocurrency, :string
    field :amount_crypto, :decimal
    field :price_usd, :decimal
    field :total_usd, :decimal
    belongs_to :account, CryptoStream.Accounts.Account

    timestamps()
  end

  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:type, :cryptocurrency, :amount_crypto, :price_usd, :total_usd, :account_id])
    |> validate_required([:type, :cryptocurrency, :amount_crypto, :price_usd, :total_usd, :account_id])
    |> validate_number(:amount_crypto, greater_than: 0)
    |> validate_number(:price_usd, greater_than: 0)
    |> validate_number(:total_usd, greater_than: 0)
    |> foreign_key_constraint(:account_id)
  end
end
