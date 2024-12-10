defmodule CryptoStream.Accounts.Domain.AccountManagerTest do
  use CryptoStream.DataCase, async: true

  alias CryptoStream.Accounts.Domain.{AccountManager, User, Account}
  alias CryptoStream.Repo
  alias Decimal, as: D

  describe "create_account/1" do
    setup do
      user_attrs = %{
        email: "test@example.com",
        username: "testuser",
        password: "valid_password",
        password_confirmation: "valid_password"
      }

      {:ok, user} =
        %User{}
        |> User.changeset(user_attrs)
        |> Repo.insert()

      %{user: user}
    end

    test "creates account with initial balance for valid user", %{user: user} do
      assert {:ok, account} = AccountManager.create_account(user)
      assert account.user_id == user.id
      assert Decimal.equal?(account.balance_usd, D.new("10000.00"))
    end
  end

  describe "get_account/1" do
    setup do
      user = Repo.insert!(%User{email: "test@example.com", username: "testuser", password_hash: "hash"})
      account = Repo.insert!(%Account{user_id: user.id, balance_usd: D.new("10000.00")})
      %{account: account}
    end

    test "returns the account when it exists", %{account: account} do
      assert {:ok, found_account} = AccountManager.get_account(account.id)
      assert found_account.id == account.id
    end

    test "returns error when account doesn't exist" do
      assert {:error, :not_found} = AccountManager.get_account(0)
    end
  end

  describe "update_balance/2" do
    setup do
      user = Repo.insert!(%User{email: "test@example.com", username: "testuser", password_hash: "hash"})
      account = Repo.insert!(%Account{user_id: user.id, balance_usd: D.new("10000.00")})
      %{account: account}
    end

    test "updates balance when new balance is valid", %{account: account} do
      new_balance = D.new("5000.00")
      assert {:ok, updated_account} = AccountManager.update_balance(account, new_balance)
      assert Decimal.equal?(updated_account.balance_usd, new_balance)
    end

    test "returns error when new balance is negative", %{account: account} do
      assert {:error, :insufficient_funds} = AccountManager.update_balance(account, D.new("-100.00"))
    end
  end

  describe "get_account_by_user/1" do
    setup do
      user = Repo.insert!(%User{email: "test@example.com", username: "testuser", password_hash: "hash"})
      account = Repo.insert!(%Account{user_id: user.id, balance_usd: D.new("10000.00")})
      %{user: user, account: account}
    end

    test "returns account when user has one", %{user: user, account: account} do
      assert {:ok, found_account} = AccountManager.get_account_by_user(user)
      assert found_account.id == account.id
    end

    test "returns error when user has no account" do
      user = Repo.insert!(%User{email: "no_account@example.com", username: "noaccountuser", password_hash: "hash"})
      assert {:error, :not_found} = AccountManager.get_account_by_user(user)
    end
  end
end
