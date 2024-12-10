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
    test "successfully buys cryptocurrency with USD amount", %{conn: conn} do
      CryptoStream.Services.MockCoingeckoClient
      |> expect(:get_prices, fn -> {:ok, %{"bitcoin" => %{"usd" => 50000.00}}} end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_usd" => "1000.00"
      })

      response = json_response(conn, 201)
      assert %{"data" => %{"id" => _id}} = response
      assert response["data"]["amount_usd"] == "1000.00000000"
      assert response["data"]["amount_crypto"] == "0.02000000" # 1000/50000
      assert response["data"]["price_usd"] == "50000.00000000"
    end

    test "successfully buys cryptocurrency with crypto amount", %{conn: conn} do
      CryptoStream.Services.MockCoingeckoClient
      |> expect(:get_prices, fn -> {:ok, %{"bitcoin" => %{"usd" => 50000.00}}} end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_crypto" => "0.02"
      })

      response = json_response(conn, 201)
      assert %{"data" => %{"id" => _id}} = response
      assert response["data"]["amount_crypto"] == "0.02000000"
      assert response["data"]["amount_usd"] == "1000.00000000" # 0.02 * 50000
      assert response["data"]["price_usd"] == "50000.00000000"
    end

    test "fails to buy cryptocurrency with insufficient balance", %{conn: conn} do
      CryptoStream.Services.MockCoingeckoClient
      |> expect(:get_prices, fn -> {:ok, %{"bitcoin" => %{"usd" => 50000.00}}} end)

      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_usd" => "200000.00"
      })

      assert json_response(conn, 422) == %{
        "errors" => %{
          "detail" => "Insufficient balance"
        }
      }
    end

    test "fails with invalid USD amount", %{conn: conn} do
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_usd" => "invalid"
      })

      assert json_response(conn, 422) == %{
        "error" => "invalid_request",
        "details" => "Invalid request"
      }
    end

    test "fails with invalid crypto amount", %{conn: conn} do
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_crypto" => "invalid"
      })

      assert json_response(conn, 422) == %{
        "error" => "invalid_request",
        "details" => "Invalid request"
      }
    end

    test "fails with missing amount parameters", %{conn: conn} do
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC"
      })

      assert json_response(conn, 422) == %{
        "error" => "invalid_request",
        "details" => "Invalid request"
      }
    end

    test "fails with both USD and crypto amounts provided", %{conn: conn} do
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_usd" => "1000.00",
        "amount_crypto" => "0.02"
      })

      assert json_response(conn, 422) == %{
        "error" => "invalid_request",
        "details" => "Cannot specify both USD and crypto amounts"
      }
    end
  end

  describe "list transactions" do
    test "lists all transactions for the authenticated user", %{conn: conn} do
      CryptoStream.Services.MockCoingeckoClient
      |> expect(:get_prices, fn -> {:ok, %{"bitcoin" => %{"usd" => 50000.00}}} end)

      # Create a transaction with USD amount
      conn = post(conn, ~p"/api/trading/buy", %{
        "cryptocurrency" => "BTC",
        "amount_usd" => "1000.00"
      })

      conn = get(conn, ~p"/api/trading/transactions")

      assert %{"data" => [transaction | _]} = json_response(conn, 200)
      assert transaction["cryptocurrency"] == "BTC"
      assert transaction["amount_usd"] == "1000.00000000"
      assert transaction["amount_crypto"] == "0.02000000"
      assert transaction["price_usd"] == "50000.00000000"
    end
  end
end
