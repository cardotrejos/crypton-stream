defmodule CryptoStreamWeb.TradingJSON do
  @moduledoc """
  JSON view module for trading-related responses.
  Follows functional programming principles with pattern matching and data transformation.
  """

  @doc """
  Renders a single transaction.
  """
  def transaction(%{transaction: transaction}) do
    %{data: transaction_to_json(transaction)}
  end

  @doc """
  Renders a list of transactions.
  """
  def transactions(%{transactions: transactions}) do
    %{data: Enum.map(transactions, &transaction_to_json/1)}
  end

  @doc """
  Renders error responses.
  """
  def error(template \\ %{})

  def error(%{error: error_type}) when error_type in [:insufficient_balance, :invalid_request] do
    %{errors: %{detail: error_message(error_type)}}
  end

  # Private functions

  defp transaction_to_json(transaction) do
    %{
      id: transaction.id,
      type: transaction.type,
      cryptocurrency: transaction.cryptocurrency,
      amount_usd: transaction.amount_usd,
      amount_crypto: transaction.amount_crypto,
      price_usd: transaction.price_usd,
      total_usd: transaction.total_usd,
      account_id: transaction.account_id,
      inserted_at: transaction.inserted_at
    }
  end

  defp error_message(:insufficient_balance), do: "Insufficient balance"
  defp error_message(:invalid_request), do: "Invalid request"
end
