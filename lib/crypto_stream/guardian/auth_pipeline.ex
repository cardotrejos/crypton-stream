defmodule CryptoStream.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :crypto_stream,
    module: CryptoStream.Guardian,
    error_handler: CryptoStream.Guardian.AuthErrorHandler

  alias CryptoStream.Repo

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug :load_account

  def load_account(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn
      user ->
        user = Repo.preload(user, :account, force: true)
        Guardian.Plug.put_current_resource(conn, user)
    end
  end
end
