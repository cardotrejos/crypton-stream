defmodule CryptoStream.AuthFixtures do
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "test#{System.unique_integer()}@example.com",
        password: "password123",
        username: "testuser#{System.unique_integer()}"
      })
      |> CryptoStream.Accounts.register_user()

    user
  end
end
