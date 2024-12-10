defmodule CryptoStream.Accounts.Ports.AccountsRepository do
  @moduledoc """
  Port interface for accounts persistence operations.
  """

  alias CryptoStream.Accounts.Domain.{User, Account}
  alias CryptoStream.Repo

  @doc """
  Gets a user by ID.
  """
  @spec get_user(integer()) :: User.t() | nil
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user by email.
  """
  @spec get_user_by_email(String.t()) :: User.t() | nil
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Gets an account by ID.
  """
  @spec get_account(integer()) :: Account.t() | nil
  def get_account(id), do: Repo.get(Account, id)

  @doc """
  Gets an account by user ID.
  """
  @spec get_account_by_user(integer()) :: Account.t() | nil
  def get_account_by_user(user_id), do: Repo.get_by(Account, user_id: user_id)

  @doc """
  Executes a multi-operation transaction.
  """
  @spec transaction(Ecto.Multi.t()) :: 
    {:ok, map()} | 
    {:error, atom(), any(), map()}
  def transaction(multi), do: Repo.transaction(multi)
end
