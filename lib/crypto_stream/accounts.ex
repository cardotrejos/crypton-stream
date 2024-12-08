defmodule CryptoStream.Accounts do
  @moduledoc """
  The Accounts context.
  This module serves as the public API for account-related operations,
  delegating to the domain layer for business logic.
  """

  alias CryptoStream.Accounts.Domain.{AuthenticationService, RegistrationService}
  alias CryptoStream.Accounts.Ports.AccountsRepository
  alias CryptoStream.Repo
  alias CryptoStream.Accounts.Domain.{User, Account}

  @doc """
  Gets a user by ID.
  """
  def get_user(id) when is_binary(id) do
    case Integer.parse(id) do
      {id, ""} -> get_user(id)
      _ -> nil
    end
  end

  def get_user(id) when is_integer(id) do
    Repo.get(User, id)
  end

  def get_user(_), do: nil

  @doc """
  Gets a user by email.
  """
  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Gets an account by ID.
  """
  def get_account(id) do
    case Repo.get(Account, id) do
      nil -> {:error, :not_found}
      account -> {:ok, account}
    end
  end

  @doc """
  Gets an account by user ID.
  """
  def get_account_by_user_id(user_id) do
    case get_user(user_id) do
      nil -> {:error, :not_found}
      user ->
        account = Repo.preload(user, :account).account
        if account, do: {:ok, account}, else: {:error, :not_found}
    end
  end

  @doc """
  Registers a new user with the given attributes.
  Creates an associated trading account with initial balance.
  """
  def register_user(attrs) do
    Repo.transaction(fn ->
      with {:ok, user} <- create_user(attrs),
           {:ok, account} <- create_account(user) do
        user
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  defp create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  defp create_account(user) do
    %Account{
      user_id: user.id,
      balance_usd: Decimal.new("10000.00")
    }
    |> Repo.insert()
  end

  @doc """
  Authenticates a user with email and password.
  Returns {:ok, user} if successful, {:error, :invalid_credentials} otherwise.
  """
  def authenticate_user(email, password) do
    AuthenticationService.authenticate_user(email, password)
  end

  def update_account_balance(account, new_balance) do
    account
    |> Account.balance_changeset(%{balance_usd: new_balance})
    |> Repo.update()
  end
end
