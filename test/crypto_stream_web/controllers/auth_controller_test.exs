defmodule CryptoStreamWeb.AuthControllerTest do
  use CryptoStreamWeb.ConnCase

  @create_attrs %{
    "user" => %{
      "email" => "test@example.com",
      "password" => "password123",
      "username" => "testuser"
    }
  }

  @invalid_attrs %{
    "user" => %{
      "email" => "invalid"
    }
  }

  @login_attrs %{
    "user" => %{
      "email" => "test@example.com",
      "password" => "password123"
    }
  }

  @invalid_login_attrs %{
    "user" => %{
      "email" => "test@example.com",
      "password" => "wrong"
    }
  }

  describe "register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/register", @create_attrs)
      assert %{"data" => data} = json_response(conn, 200)
      assert data["email"] == "test@example.com"
      assert data["username"] == "testuser"
      assert data["token"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/register", @invalid_attrs)
      assert %{"errors" => errors} = json_response(conn, 422)
      assert errors["email"] == ["must be a valid email format"]
      assert errors["password"] == ["can't be blank"]
      assert errors["username"] == ["can't be blank"]
    end
  end

  describe "login user" do
    setup [:create_user]

    test "renders user when credentials are valid", %{conn: conn} do
      conn = post(conn, ~p"/api/login", @login_attrs)
      assert %{"data" => data} = json_response(conn, 200)
      assert data["email"] == "test@example.com"
      assert data["username"] == "testuser"
      assert data["token"]
    end

    test "renders errors when credentials are invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/login", @invalid_login_attrs)
      assert %{"errors" => %{"detail" => "Invalid email or password"}} = json_response(conn, 401)
    end
  end

  defp create_user(_) do
    {:ok, user} = CryptoStream.Accounts.register_user(@create_attrs["user"])
    %{user: user}
  end
end
