defmodule CryptoStreamWeb.AuthController do
  use CryptoStreamWeb, :controller

  alias CryptoStream.Accounts
  alias CryptoStream.Guardian

  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(:created)
        |> render("user.json", %{user: user, token: token})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", changeset: changeset)
    end
  end

  # Handle parameters nested under "user"
  def login(conn, %{"user" => %{"email" => email, "password" => password}}) do
    do_login(conn, email, password)
  end

  # Handle top-level parameters
  def login(conn, %{"email" => email, "password" => password}) do
    do_login(conn, email, password)
  end

  defp do_login(conn, email, password) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(:ok)
        |> render("user.json", %{user: user, token: token})

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", message: "Invalid credentials")
    end
  end
end
