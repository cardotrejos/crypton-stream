defmodule CryptoStream.Accounts do
  @moduledoc """
  The Accounts context.
  This module serves as the public API for account-related operations,
  delegating to the domain layer for business logic.
  """

  alias CryptoStream.Repo
  alias CryptoStream.Accounts.Domain.{User, Account}
  import Ecto.Changeset

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
  def register_user(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Ecto.Multi.insert(:account, fn %{user: user} ->
      %Account{}
      |> cast(%{balance_usd: "10000.00", user_id: user.id}, [:balance_usd, :user_id])
      |> validate_required([:balance_usd, :user_id])
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, account: account}} -> 
        user = %{user | account: account}
        {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Updates an account's balance.
  """
  def update_account_balance(account, new_balance) do
    account
    |> Account.balance_changeset(%{balance_usd: new_balance})
    |> Repo.update()
  end

  @doc """
  Authenticates a user with email and password.
  """
  def authenticate_user(email, password) do
    user = get_user_by_email(email)
    |> Repo.preload(:account)
    
    case user do
      {:ok, user} -> 
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
      {:error, :not_found} ->
        {:error, :invalid_credentials}
    end
  end
end
