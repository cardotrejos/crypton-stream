defmodule CryptoStream.Accounts do
  @moduledoc """
  The Accounts context.
  This module serves as the public API for account-related operations,
  delegating to the domain layer for business logic.
  """

  alias CryptoStream.Repo
  alias CryptoStream.Accounts.Domain.{User, Authentication, AccountManager}
  alias Ecto.Multi

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
  def get_user_by_email(email), do: Authentication.get_user_by_email(email)

  @doc """
  Gets an account by ID.
  """
  def get_account(id), do: AccountManager.get_account(id)

  @doc """
  Gets an account by user ID.
  """
  def get_account_by_user_id(user_id) do
    with user when not is_nil(user) <- get_user(user_id) do
      AccountManager.get_account_by_user(user)
    else
      nil -> {:error, :not_found}
    end
  end

  @doc """
  Registers a new user with the given attributes.
  Creates an associated trading account with initial balance.
  """
  def register_user(attrs \\ %{}) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Multi.run(:account, fn _repo, %{user: user} ->
      AccountManager.create_account(user)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, account: account}} -> 
        {:ok, %{user | account: account}}
      {:error, operation, changeset, _changes} -> 
        {:error, {operation, changeset}}
    end
  end

  @doc """
  Updates an account's balance.
  """
  def update_account_balance(account, new_balance) do
    AccountManager.update_balance(account, new_balance)
  end

  @doc """
  Authenticates a user with email and password.
  """
  def authenticate_user(email, password) do
    Authentication.authenticate(email, password)
  end
end
