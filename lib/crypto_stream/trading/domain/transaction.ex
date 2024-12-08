defmodule CryptoStream.Trading.Domain.Transaction do
  @moduledoc """
  Domain entity representing a cryptocurrency trading transaction.
  This is the core domain entity that encapsulates the business rules
  for cryptocurrency transactions.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias CryptoStream.Accounts.Account
  alias Decimal, as: D

  @type t :: %__MODULE__{
    type: :buy | :sell,
    cryptocurrency: String.t(),
    amount_crypto: Decimal.t(),
    price_usd: Decimal.t(),
    total_usd: Decimal.t(),
    account_id: integer(),
    account: Account.t() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }

  schema "transactions" do
    field :type, Ecto.Enum, values: [:buy, :sell]
    field :cryptocurrency, :string
    field :amount_crypto, :decimal
    field :price_usd, :decimal
    field :total_usd, :decimal
    belongs_to :account, Account

    timestamps()
  end

  @required_fields [:type, :cryptocurrency, :amount_crypto, :price_usd, :total_usd, :account_id]

  @doc """
  Creates a new transaction changeset.
  """
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
    |> validate_number(:amount_crypto, greater_than: 0)
    |> validate_number(:price_usd, greater_than: 0)
    |> validate_number(:total_usd, greater_than: 0)
    |> validate_total_usd()
    |> foreign_key_constraint(:account_id)
  end

  @doc """
  Creates a new buy transaction.
  """
  def new_buy(cryptocurrency, amount_crypto, price_usd, account_id) when is_binary(cryptocurrency) and is_binary(amount_crypto) and is_binary(price_usd) do
    with {:ok, amount} <- parse_decimal(amount_crypto),
         {:ok, price} <- parse_decimal(price_usd),
         {:ok, total} <- calculate_total_usd(amount, price) do
      changeset(%__MODULE__{}, %{
        type: :buy,
        cryptocurrency: cryptocurrency,
        amount_crypto: amount,
        price_usd: price,
        total_usd: total,
        account_id: account_id
      })
    else
      {:error, reason} -> 
        # Return an invalid changeset with errors
        %__MODULE__{}
        |> changeset(%{})
        |> add_error(:base, "Invalid decimal values")
    end
  end

  # Private functions

  defp validate_total_usd(changeset) do
    case {get_field(changeset, :amount_crypto), get_field(changeset, :price_usd), get_field(changeset, :total_usd)} do
      {amount, price, total} when not is_nil(amount) and not is_nil(price) and not is_nil(total) ->
        expected_total = D.mult(amount, price)
        if D.equal?(total, expected_total) do
          changeset
        else
          add_error(changeset, :total_usd, "must equal amount_crypto * price_usd")
        end
      _ ->
        changeset
    end
  end

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

  defp calculate_total_usd(amount, price) do
    {:ok, D.mult(amount, price)}
  rescue
    _ -> {:error, :decimal_error}
  end
end
