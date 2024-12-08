defmodule CryptoStream.Accounts.Domain.AuthenticationService do
  @moduledoc """
  Domain service handling user authentication logic.
  """

  alias CryptoStream.Accounts.Domain.User
  alias CryptoStream.Repo

  @type auth_result :: {:ok, User.t()} | {:error, :invalid_credentials}

  @doc """
  Authenticates a user with email and password.
  Returns {:ok, user} if successful, {:error, :invalid_credentials} otherwise.
  """
  @spec authenticate_user(String.t(), String.t()) :: auth_result
  def authenticate_user(email, password) do
    user = Repo.get_by(User, email: email)

    case user do
      nil ->
        {:error, :invalid_credentials}
      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
