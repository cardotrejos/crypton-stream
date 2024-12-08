defmodule CryptoStreamWeb.TradingJSON do
  def transaction(%{transaction: transaction}) do
    %{
      data: %{
        id: transaction.id,
        type: transaction.type,
        cryptocurrency: transaction.cryptocurrency,
        amount_usd: transaction.amount_usd,
        account_id: transaction.account_id,
        inserted_at: transaction.inserted_at
      }
    }
  end

  def transactions(%{transactions: transactions}) do
    %{
      data: Enum.map(transactions, fn transaction ->
        %{
          id: transaction.id,
          type: transaction.type,
          cryptocurrency: transaction.cryptocurrency,
          amount_usd: transaction.amount_usd,
          account_id: transaction.account_id,
          inserted_at: transaction.inserted_at
        }
      end)
    }
  end
end
