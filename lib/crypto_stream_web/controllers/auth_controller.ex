defmodule CryptoStreamWeb.AuthController do
  use CryptoStreamWeb, :controller

  alias CryptoStream.Accounts
  alias CryptoStream.Accounts.Domain.AuthenticationService
  alias CryptoStream.Repo

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        user = Repo.preload(user, :account)
        {:ok, token, _claims} = CryptoStream.Guardian.encode_and_sign(user)
        render(conn, :user, %{user: user, token: token})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, %{changeset: changeset})
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    do_login(conn, email, password)
  end

  # Handle top-level parameters
  def login(conn, %{"email" => email, "password" => password}) do
    do_login(conn, email, password)
  end

  defp do_login(conn, email, password) do
    case AuthenticationService.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = CryptoStream.Guardian.encode_and_sign(user)
        json(conn, %{"data" => %{
          "email" => user.email,
          "username" => user.username,
          "token" => token
        }})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{"errors" => %{"detail" => "Invalid email or password"}})
    end
  end
end
