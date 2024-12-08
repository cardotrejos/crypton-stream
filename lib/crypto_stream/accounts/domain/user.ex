defmodule CryptoStream.Accounts.Domain.User do
  @moduledoc """
  Domain entity representing a user in the system.
  This module encapsulates user-related business rules and validations.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias CryptoStream.Accounts.Domain.Account

  @type t :: %__MODULE__{
    email: String.t(),
    username: String.t(),
    password_hash: String.t(),
    account: Account.t() | nil,
    inserted_at: DateTime.t() | nil,
    updated_at: DateTime.t() | nil
  }

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :username, :string
    has_one :account, Account

    timestamps()
  end

  @email_regex ~r/^[^\s]+@[^\s]+$/
  @min_password_length 6

  @doc """
  Creates a new user changeset with the given attributes.
  Enforces business rules:
  - Email must be valid format and unique
  - Username must be unique
  - Password must be at least 6 characters
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_required([:email, :password, :username])
    |> validate_format(:email, @email_regex, message: "must be a valid email format")
    |> validate_length(:password, min: @min_password_length, 
        message: "must be at least #{@min_password_length} characters")
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> hash_password()
  end

  @doc """
  Verifies if the given password matches the user's password hash.
  """
  def verify_password(%__MODULE__{password_hash: hash}, password) when is_binary(hash) and is_binary(password) do
    Bcrypt.verify_pass(password, hash)
  end

  def verify_password(_, _), do: false

  # Private functions

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp hash_password(changeset), do: changeset
end
