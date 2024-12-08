defmodule CryptoStream.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :crypto_stream,
    module: CryptoStream.Guardian,
    error_handler: CryptoStream.Guardian.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
