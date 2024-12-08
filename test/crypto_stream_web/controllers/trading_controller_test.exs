defmodule CryptoStreamWeb.TradingControllerTest do
  use CryptoStreamWeb.ConnCase
  import Mox

  setup :verify_on_exit!

  @create_attrs %{
    "email" => "test@example.com",
    "password" => "password123",
    "username" => "testuser"
  }

  setup %{conn: conn} do
    {:ok, user} = CryptoStream.Accounts.register_user(@create_attrs)
    user = CryptoStream.Repo.preload(user, :account)
    account = user.account

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> authenticate_user(user)

    {:ok, conn: conn, user: user, account: account}
  end

  describe "buy cryptocurrency" do
    test "successfully buys cryptocurrency with sufficient balance", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_price, fn "bitcoin", "usd" ->
        {:ok, "50000.00"}
      end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "bitcoin",
        "amount_usd" => "1000.00",
        "price_usd" => "50000.00"
      })

      assert %{"data" => %{"id" => _id}} = json_response(conn, 201)
    end

    test "fails to buy cryptocurrency with insufficient balance", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_price, fn "bitcoin", "usd" ->
        {:ok, "50000.00"}
      end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "bitcoin",
        "amount_usd" => "20000.00",
        "price_usd" => "50000.00"
      })

      assert json_response(conn, 422) == %{
        "errors" => %{
          "detail" => "Insufficient balance"
        }
      }
    end

    test "fails with invalid parameters", %{conn: conn} do
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "bitcoin",
        "amount_usd" => "invalid",
        "price_usd" => "50000.00"
      })

      assert json_response(conn, 422) == %{
        "errors" => %{
          "detail" => "Invalid request"
        }
      }
    end
  end

  describe "list transactions" do
    test "lists all transactions for the authenticated user", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_price, fn "bitcoin", "usd" ->
        {:ok, "50000.00"}
      end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "bitcoin",
        "amount_usd" => "1000.00",
        "price_usd" => "50000.00"
      })

      conn = get(conn, ~p"/api/trading/transactions")

      assert %{"data" => [transaction | _]} = json_response(conn, 200)
      assert transaction["cryptocurrency"] == "bitcoin"
      assert transaction["amount_usd"] == "1000.00000000"
    end
  end
end
