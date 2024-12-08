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

  def error(%{changeset: changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
    }
  end

  def error(%{message: message}) do
    %{
      errors: %{
        detail: message
      }
    }
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
