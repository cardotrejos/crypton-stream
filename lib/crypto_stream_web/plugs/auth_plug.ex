defmodule CryptoStreamWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias CryptoStreamWeb.Guardian
  alias CryptoStream.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Guardian.decode_and_verify(token),
         {:ok, user} <- Guardian.resource_from_claims(claims),
         {:ok, account} <- Accounts.get_account_by_user_id(user.id) do
      conn
      |> assign(:current_user, user)
      |> assign(:current_account, account)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", message: "Unauthorized")
        |> halt()
    end
  end
end
