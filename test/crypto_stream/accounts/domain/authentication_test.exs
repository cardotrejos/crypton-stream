defmodule CryptoStream.Accounts.Domain.AuthenticationTest do
  use CryptoStream.DataCase, async: true

  alias CryptoStream.Accounts.Domain.{Authentication, User}
  alias CryptoStream.Repo

  describe "authenticate/2" do
    setup do
      valid_attrs = %{
        email: "test@example.com",
        username: "testuser",
        password: "valid_password",
        password_confirmation: "valid_password"
      }

      {:ok, user} =
        %User{}
        |> User.changeset(valid_attrs)
        |> Repo.insert()

      %{user: user, password: valid_attrs.password}
    end

    test "returns ok tuple with user when credentials are valid", %{user: user, password: password} do
      assert {:ok, returned_user} = Authentication.authenticate(user.email, password)
      assert returned_user.id == user.id
    end

    test "returns error when email is not found" do
      assert {:error, :not_found} = Authentication.authenticate("wrong@email.com", "any_password")
    end

    test "returns error when password is invalid", %{user: user} do
      assert {:error, :invalid_credentials} = Authentication.authenticate(user.email, "wrong_password")
    end

    test "returns error when email is nil" do
      assert {:error, :not_found} = Authentication.authenticate(nil, "any_password")
    end

    test "returns error when password is nil", %{user: user} do
      assert {:error, :invalid_credentials} = Authentication.authenticate(user.email, nil)
    end
  end
end
