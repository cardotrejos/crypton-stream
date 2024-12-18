defmodule CryptoStream.Guardian.AuthErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type), details: inspect(reason)})
    
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
