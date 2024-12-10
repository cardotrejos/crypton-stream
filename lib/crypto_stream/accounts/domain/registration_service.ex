defmodule CryptoStream.Accounts.Domain.RegistrationService do
  @moduledoc """
  Domain service handling user registration logic.
  """

  alias CryptoStream.Accounts.Domain.{User, Account}
  alias CryptoStream.Accounts.Ports.AccountsRepository
  alias Ecto.Multi

  @type registration_result :: {:ok, %{user: User.t(), account: Account.t()}} | {:error, atom(), any(), map()}

  @doc """
  Registers a new user and creates their associated trading account.
  Returns {:ok, %{user: user, account: account}} if successful.
  """
  @spec register_user(map(), module()) :: registration_result
  def register_user(attrs, repo \\ AccountsRepository) do
    Multi.new()
    |> Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Multi.insert(:account, fn %{user: user} -> 
      Account.new_account(user.id)
    end)
    |> repo.transaction()
  end
end
