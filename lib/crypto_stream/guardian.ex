defmodule CryptoStream.Guardian do
  use Guardian, otp_app: :crypto_stream
  alias CryptoStream.Repo

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case CryptoStream.Accounts.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, Repo.preload(user, :account)}
    end
  end
end
