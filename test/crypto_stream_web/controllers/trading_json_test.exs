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
        amount_crypto: D.new("0.02"),
        price_usd: D.new("50000.00"),
        account_id: 1,
        inserted_at: ~N[2024-01-01 00:00:00]
      }

      assert %{
        data: %{
          id: 1,
          type: "buy",
          cryptocurrency: "BTC",
          amount_usd: amount_usd,
          amount_crypto: amount_crypto,
          price_usd: price,
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        }
      } = TradingJSON.transaction(%{transaction: transaction})

      assert Decimal.equal?(amount_usd, transaction.amount_usd)
      assert Decimal.equal?(amount_crypto, transaction.amount_crypto)
      assert Decimal.equal?(price, transaction.price_usd)
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
          amount_crypto: D.new("0.02"),
          price_usd: D.new("50000.00"),
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        },
        %{
          id: 2,
          type: "buy",
          cryptocurrency: "ETH",
          amount_usd: D.new("500.00"),
          amount_crypto: D.new("0.25"),
          price_usd: D.new("2000.00"),
          account_id: 1,
          inserted_at: ~N[2024-01-01 00:00:00]
        }
      ]

      assert %{data: rendered_transactions} = TradingJSON.transactions(%{transactions: transactions})
      assert length(rendered_transactions) == length(transactions)

      Enum.zip(rendered_transactions, transactions)
      |> Enum.each(fn {rendered, original} ->
        assert rendered.id == original.id
        assert rendered.type == original.type
        assert rendered.cryptocurrency == original.cryptocurrency
        assert Decimal.equal?(D.new(rendered.amount_usd), original.amount_usd)
        assert Decimal.equal?(D.new(rendered.amount_crypto), original.amount_crypto)
        assert Decimal.equal?(D.new(rendered.price_usd), original.price_usd)
        assert rendered.account_id == original.account_id
        assert rendered.inserted_at == original.inserted_at
      end)
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
