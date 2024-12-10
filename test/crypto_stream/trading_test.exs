defmodule CryptoStream.TradingTest do
  use CryptoStream.DataCase

  alias CryptoStream.Trading
  alias CryptoStream.Accounts
  alias CryptoStream.Repo
  alias Decimal, as: D

  setup do
    {:ok, user} = Accounts.register_user(%{
      "email" => "test@example.com",
      "password" => "password123",
      "username" => "testuser"
    })
    account = Repo.preload(user, :account).account
    {:ok, account: account}
  end

  describe "buy_cryptocurrency_with_usd/4" do
    test "successfully buys cryptocurrency with sufficient USD balance", %{account: account} do
      {:ok, transaction} = Trading.buy_cryptocurrency_with_usd(account, "bitcoin", D.new("1000.00"), D.new("50000.00"))
      assert transaction.type == "buy"
      assert transaction.cryptocurrency == "bitcoin"
      assert transaction.amount_usd == D.new("1000.00000000")
      assert transaction.amount_crypto == D.new("0.02000000") # 1000/50000
      assert transaction.price_usd == D.new("50000.00000000")
      assert transaction.account_id == account.id
    end

    test "fails to buy cryptocurrency with insufficient USD balance", %{account: account} do
      assert {:error, :insufficient_balance} =
        Trading.buy_cryptocurrency_with_usd(account, "bitcoin", D.new("20000.00"), D.new("50000.00"))
    end
  end

  describe "buy_cryptocurrency_with_crypto/4" do
    test "successfully buys cryptocurrency with sufficient USD balance for crypto amount", %{account: account} do
      {:ok, transaction} = Trading.buy_cryptocurrency_with_crypto(account, "bitcoin", D.new("0.02"), D.new("50000.00"))
      assert transaction.type == "buy"
      assert transaction.cryptocurrency == "bitcoin"
      assert transaction.amount_crypto == D.new("0.02000000")
      assert transaction.amount_usd == D.new("1000.00000000") # 0.02 * 50000
      assert transaction.price_usd == D.new("50000.00000000")
      assert transaction.account_id == account.id
    end

    test "fails to buy cryptocurrency with insufficient USD balance for crypto amount", %{account: account} do
      assert {:error, :insufficient_balance} =
        Trading.buy_cryptocurrency_with_crypto(account, "bitcoin", D.new("0.4"), D.new("50000.00"))
    end
  end

  describe "list_account_transactions/1" do
    test "returns all transactions for an account", %{account: account} do
      # Create a transaction with USD amount
      {:ok, transaction1} = Trading.buy_cryptocurrency_with_usd(account, "bitcoin", D.new("1000.00"), D.new("50000.00"))
      
      # Create a transaction with crypto amount
      {:ok, transaction2} = Trading.buy_cryptocurrency_with_crypto(account, "bitcoin", D.new("0.02"), D.new("50000.00"))
      
      transactions = Trading.list_account_transactions(account)
      assert length(transactions) == 2
      
      # Check first transaction (USD amount)
      assert Enum.any?(transactions, fn t -> 
        t.id == transaction1.id and
        t.amount_usd == D.new("1000.00000000") and
        t.amount_crypto == D.new("0.02000000")
      end)
      
      # Check second transaction (crypto amount)
      assert Enum.any?(transactions, fn t -> 
        t.id == transaction2.id and
        t.amount_crypto == D.new("0.02000000") and
        t.amount_usd == D.new("1000.00000000")
      end)
    end

    test "returns empty list when account has no transactions", %{account: account} do
      assert Trading.list_account_transactions(account) == []
    end
  end
end
