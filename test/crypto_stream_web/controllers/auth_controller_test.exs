defmodule CryptoStreamWeb.AuthControllerTest do
  use CryptoStreamWeb.ConnCase

  import CryptoStream.AuthFixtures

  @create_attrs %{
    email: "test@example.com",
    password: "password123",
    username: "testuser"
  }
  @invalid_attrs %{email: nil, password: nil, username: nil}

  describe "register user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/register", user: @create_attrs)
      assert %{"data" => data} = json_response(conn, 201)
      assert data["email"] == @create_attrs.email
      assert data["username"] == @create_attrs.username
      assert data["token"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/register", user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when email is already taken", %{conn: conn} do
      user_fixture(@create_attrs)
      conn = post(conn, ~p"/api/register", user: @create_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "login user" do
    setup [:create_user]

    test "renders user when credentials are valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/login", email: user.email, password: @create_attrs.password)
      assert %{"data" => data} = json_response(conn, 200)
      assert data["email"] == user.email
      assert data["username"] == user.username
      assert data["token"]
    end

    test "renders errors when credentials are invalid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/api/login", email: user.email, password: "wrong")
      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end
end
