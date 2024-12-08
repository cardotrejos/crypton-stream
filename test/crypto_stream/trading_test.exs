defmodule CryptoStream.TradingTest do
  use CryptoStream.DataCase

  alias CryptoStream.Trading
  alias CryptoStream.Accounts
  alias CryptoStream.Repo

  setup do
    {:ok, user} = Accounts.register_user(%{
      "email" => "test@example.com",
      "password" => "password123",
      "username" => "testuser"
    })
    account = Repo.preload(user, :account).account
    {:ok, account: account}
  end

  describe "buy_cryptocurrency/4" do
    test "successfully buys cryptocurrency with sufficient balance", %{account: account} do
      {:ok, transaction} = Trading.buy_cryptocurrency(account, "bitcoin", Decimal.new("1000.00"), Decimal.new("50000.00"))
      assert transaction.type == "buy"
      assert transaction.cryptocurrency == "bitcoin"
      assert transaction.amount_usd == Decimal.new("1000.00000000")
      assert transaction.account_id == account.id
    end

    test "fails to buy cryptocurrency with insufficient balance", %{account: account} do
      assert {:error, :insufficient_balance} =
        Trading.buy_cryptocurrency(account, "bitcoin", Decimal.new("20000.00"), Decimal.new("50000.00"))
    end
  end

  describe "list_account_transactions/1" do
    test "returns all transactions for an account", %{account: account} do
      {:ok, _transaction} = Trading.buy_cryptocurrency(account, "bitcoin", Decimal.new("1000.00"), Decimal.new("50000.00"))
      transactions = Trading.list_account_transactions(account)
      assert length(transactions) == 1
      transaction = hd(transactions)
      assert transaction.account_id == account.id
      assert transaction.amount_usd == Decimal.new("1000.00000000")
    end
  end
end
