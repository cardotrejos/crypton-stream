defmodule CryptoStream.TradingTest do
  use CryptoStream.DataCase

  alias CryptoStream.Trading
  alias CryptoStream.Accounts.Account

  describe "buy_cryptocurrency/4" do
    setup do
      {:ok, user} = CryptoStream.Accounts.register_user(%{
        email: "test@example.com",
        username: "testuser",
        password: "password123"
      })
      
      {:ok, account} = %Account{}
      |> Account.changeset(%{user_id: user.id, balance_usd: Decimal.new("10000.00")})
      |> Repo.insert()

      %{account: account}
    end

    test "successfully buys cryptocurrency with sufficient balance", %{account: account} do
      cryptocurrency = "BTC"
      amount = "0.1"  # Reduced amount to ensure it's within balance
      price = "40000.00"

      assert {:ok, %{transaction: transaction, account: updated_account}} = 
        Trading.buy_cryptocurrency(account.id, cryptocurrency, amount, price)

      # Verify transaction details
      assert transaction.type == :buy
      assert transaction.cryptocurrency == cryptocurrency
      assert Decimal.equal?(transaction.amount_crypto, Decimal.new(amount))
      assert Decimal.equal?(transaction.price_usd, Decimal.new(price))
      assert Decimal.equal?(transaction.total_usd, Decimal.new("4000.00"))

      # Verify account balance was updated
      assert Decimal.equal?(
        updated_account.balance_usd,
        Decimal.sub(Decimal.new("10000.00"), Decimal.new("4000.00"))
      )
    end

    test "fails to buy cryptocurrency with insufficient balance", %{account: account} do
      cryptocurrency = "BTC"
      amount = "1.0"
      price = "50000.00"  # Total cost would be 50,000 USD

      assert {:error, :insufficient_balance} = 
        Trading.buy_cryptocurrency(account.id, cryptocurrency, amount, price)

      # Verify account balance remains unchanged
      updated_account = Repo.get(Account, account.id)
      assert Decimal.equal?(updated_account.balance_usd, Decimal.new("10000.00"))
    end
  end

  describe "list_account_transactions/1" do
    setup do
      {:ok, user} = CryptoStream.Accounts.register_user(%{
        email: "test2@example.com",
        username: "testuser2",
        password: "password123"
      })
      
      {:ok, account} = %Account{}
      |> Account.changeset(%{user_id: user.id, balance_usd: Decimal.new("10000.00")})
      |> Repo.insert()

      %{account: account}
    end

    test "returns all transactions for an account", %{account: account} do
      # Create some test transactions
      {:ok, _} = Trading.buy_cryptocurrency(account.id, "BTC", "0.1", "40000.00")
      
      # Add a delay to ensure different timestamps
      Process.sleep(100)
      
      {:ok, _} = Trading.buy_cryptocurrency(account.id, "ETH", "1.0", "2000.00")

      transactions = Trading.list_account_transactions(account.id)
      assert length(transactions) == 2
      
      # Verify transactions are returned in descending order
      [first, second] = transactions
      assert first.cryptocurrency == "ETH"
      assert second.cryptocurrency == "BTC"
    end
  end
end
