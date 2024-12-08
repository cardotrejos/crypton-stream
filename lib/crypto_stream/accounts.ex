defmodule CryptoStream.Accounts do
  alias CryptoStream.Repo
  alias CryptoStream.Accounts.{User, Account}
  import Ecto.Changeset

  def get_user(id), do: Repo.get(User, id)
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  def register_user(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, User.changeset(%User{}, attrs))
    |> Ecto.Multi.insert(:account, fn %{user: user} ->
      %Account{}
      |> cast(%{balance_usd: "10000.00", user_id: user.id}, [:balance_usd, :user_id])
      |> validate_required([:balance_usd, :user_id])
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  def authenticate_user(email, password) do
    user = get_user_by_email(email)
    case user do
      nil -> {:error, :invalid_credentials}
      user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end
end
