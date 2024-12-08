defmodule CryptoStream.Accounts.Domain.Authentication do
  @moduledoc """
  Domain module responsible for user authentication logic.
  """

  alias CryptoStream.Accounts.Domain.User
  alias CryptoStream.Repo

  @type authentication_result :: {:ok, User.t()} | {:error, :invalid_credentials | :not_found}

  @doc """
  Authenticates a user with email and password.
  Returns {:ok, user} if successful, {:error, :invalid_credentials} if password is wrong,
  or {:error, :not_found} if user doesn't exist.
  """
  @spec authenticate(String.t() | nil, String.t() | nil) :: authentication_result
  def authenticate(nil, _password), do: {:error, :not_found}
  def authenticate(_email, nil), do: {:error, :invalid_credentials}
  
  def authenticate(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_user_by_email(email),
         true <- verify_password(user, password) do
      {:ok, user}
    else
      false -> {:error, :invalid_credentials}
      error -> error
    end
  end

  @doc """
  Gets a user by email.
  Returns {:ok, user} if found, {:error, :not_found} otherwise.
  """
  @spec get_user_by_email(String.t() | nil) :: {:ok, User.t()} | {:error, :not_found}
  def get_user_by_email(nil), do: {:error, :not_found}
  
  def get_user_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, Repo.preload(user, :account)}
    end
  end

  @spec verify_password(User.t(), String.t()) :: boolean
  defp verify_password(%User{} = user, password) when is_binary(password) do
    Bcrypt.verify_pass(password, user.password_hash)
  end

  defp verify_password(_, _), do: false
end
