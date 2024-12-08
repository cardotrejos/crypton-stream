defmodule CryptoStreamWeb.AuthController do
  use CryptoStreamWeb, :controller

  alias CryptoStream.Accounts
  alias CryptoStream.Accounts.Domain.AuthenticationService
  alias CryptoStream.Repo

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        user = Repo.preload(user, :account)
        {:ok, token, _claims} = CryptoStreamWeb.Guardian.encode_and_sign(user)
        render(conn, :user, %{user: user, token: token})
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, %{changeset: changeset})
    end
  end

  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case AuthenticationService.authenticate_user(email, password) do
      {:ok, user} ->
        user = Repo.preload(user, :account)
        {:ok, token, _claims} = CryptoStreamWeb.Guardian.encode_and_sign(user)
        render(conn, :user, %{user: user, token: token})
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, %{message: "Invalid email or password"})
    end
  end
end
