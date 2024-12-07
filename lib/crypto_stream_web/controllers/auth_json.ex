defmodule CryptoStreamWeb.AuthJSON do
  def user(%{user: user, token: token}) do
    %{
      data: %{
        id: user.id,
        email: user.email,
        username: user.username,
        token: token
      }
    }
  end
end
