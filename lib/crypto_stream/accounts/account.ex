defmodule CryptoStream.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :balance_usd, :decimal, default: Decimal.new("10000.00")  # Start with 10,000 USD
    belongs_to :user, CryptoStream.Accounts.User
    has_many :transactions, CryptoStream.Trading.Transaction

    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:balance_usd, :user_id])
    |> validate_required([:balance_usd, :user_id])
    |> validate_number(:balance_usd, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:user_id)
  end
end
