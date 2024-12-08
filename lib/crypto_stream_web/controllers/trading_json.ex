defmodule CryptoStreamWeb.TradingJSON do
  def transaction(%{transaction: transaction, account: account}) do
    %{
      transaction: %{
        id: transaction.id,
        type: transaction.type,
        cryptocurrency: transaction.cryptocurrency,
        amount_crypto: transaction.amount_crypto,
        price_usd: transaction.price_usd,
        total_usd: transaction.total_usd,
        inserted_at: transaction.inserted_at
      },
      account: %{
        id: account.id,
        balance_usd: account.balance_usd
      }
    }
  end

  def transactions(%{transactions: transactions}) do
    %{
      transactions: Enum.map(transactions, fn transaction ->
        %{
          id: transaction.id,
          type: transaction.type,
          cryptocurrency: transaction.cryptocurrency,
          amount_crypto: transaction.amount_crypto,
          price_usd: transaction.price_usd,
          total_usd: transaction.total_usd,
          inserted_at: transaction.inserted_at
        }
      end)
    }
  end
end
