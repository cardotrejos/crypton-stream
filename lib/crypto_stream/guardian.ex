defmodule CryptoStream.Guardian do
  use Guardian, otp_app: :crypto_stream

  alias CryptoStream.Accounts.Domain.User

  def subject_for_token(%{user: %User{} = user}, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = CryptoStream.Accounts.get_user(id)
    |> Repo.preload(:account)

    case user do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
