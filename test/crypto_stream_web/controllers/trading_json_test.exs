defmodule CryptoStreamWeb.TradingJSONTest do
  use CryptoStreamWeb.ConnCase, async: true

  alias CryptoStreamWeb.TradingJSON
  alias Decimal, as: D

  describe "transaction/1" do
    test "renders transaction data" do
      transaction = %{
        id: 1,
        type: "buy",
        cryptocurrency: "BTC",
        amount_usd: D.new("1000.00"),
        price_usd: D.new("50000.00"),
        total_usd: D.new("1000.00"),
        account_id: 1,
        inserted_at: ~N[2024-01-01 00:00:00]
      }

      assert %{
        data: %{
          id: 1,
          type: "buy",
          cryptocurrency: "BTC",
          amount_usd: amount,
          price_usd: price,
          total_usd: total,
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        }
      } = TradingJSON.transaction(%{transaction: transaction})

      assert Decimal.equal?(amount, transaction.amount_usd)
      assert Decimal.equal?(price, transaction.price_usd)
      assert Decimal.equal?(total, transaction.total_usd)
    end
  end

  describe "transactions/1" do
    test "renders list of transactions" do
      transactions = [
        %{
          id: 1,
          type: "buy",
          cryptocurrency: "BTC",
          amount_usd: D.new("1000.00"),
          price_usd: D.new("50000.00"),
          total_usd: D.new("1000.00"),
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        },
        %{
          id: 2,
          type: "sell",
          cryptocurrency: "ETH",
          amount_usd: D.new("500.00"),
          price_usd: D.new("3000.00"),
          total_usd: D.new("500.00"),
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        }
      ]

      assert %{data: rendered_transactions} = TradingJSON.transactions(%{transactions: transactions})
      assert length(rendered_transactions) == 2
      assert Enum.all?(rendered_transactions, &(&1.id in [1, 2]))
    end

    test "renders empty list for no transactions" do
      assert %{data: []} = TradingJSON.transactions(%{transactions: []})
    end
  end

  describe "error/1" do
    test "renders insufficient balance error" do
      assert %{errors: %{detail: "Insufficient balance"}} =
               TradingJSON.error(%{error: :insufficient_balance})
    end

    test "renders invalid request error" do
      assert %{errors: %{detail: "Invalid request"}} =
               TradingJSON.error(%{error: :invalid_request})
    end
  end
end
