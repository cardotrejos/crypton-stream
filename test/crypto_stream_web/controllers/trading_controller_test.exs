defmodule CryptoStreamWeb.TradingControllerTest do
  use CryptoStreamWeb.ConnCase
  alias CryptoStream.Accounts.Account
  alias CryptoStream.Repo

  setup %{conn: conn} do
    # Create user with account
    {:ok, user} = CryptoStream.Accounts.register_user(%{
      email: "test@example.com",
      username: "testuser",
      password: "password123"
    })
    
    {:ok, account} = %Account{}
    |> Account.changeset(%{user_id: user.id})
    |> Repo.insert()

    # Reload user with account
    user = Repo.preload(user, :account)

    # Authenticate user
    {:ok, token, _claims} = CryptoStream.Guardian.encode_and_sign(user)
    conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")

    %{conn: conn, user: user, account: account}
  end

  describe "buy cryptocurrency" do
    test "successfully buys cryptocurrency with sufficient balance", %{conn: conn} do
      buy_params = %{
        "cryptocurrency" => "BTC",
        "amount" => "0.1"
      }

      conn = post(conn, ~p"/api/trading/buy", buy_params)
      response = json_response(conn, 200)
      
      assert response["transaction"]["type"] == "buy"
      assert response["transaction"]["cryptocurrency"] == "BTC"
      assert response["transaction"]["amount_crypto"] == "0.1"
      assert response["account"]["balance_usd"]
    end

    test "fails to buy cryptocurrency with insufficient balance", %{conn: conn} do
      # Try to buy more than the account balance allows
      buy_params = %{
        "cryptocurrency" => "BTC",
        "amount" => "10.0"  # This would cost more than the initial balance
      }

      conn = post(conn, ~p"/api/trading/buy", buy_params)
      assert json_response(conn, 422) == %{"error" => "Insufficient balance"}
    end

    test "fails with invalid parameters", %{conn: conn} do
      # Missing required parameters
      conn = post(conn, ~p"/api/trading/buy", %{})
      assert json_response(conn, 422) == %{"error" => "Invalid parameters. Required: cryptocurrency and amount"}

      # Invalid amount format
      conn = post(conn, ~p"/api/trading/buy", %{"cryptocurrency" => "BTC", "amount" => "invalid"})
      assert json_response(conn, 422)["error"]
    end

    test "fails without authentication", %{conn: conn} do
      conn = conn
      |> delete_req_header("authorization")
      |> post(~p"/api/trading/buy", %{"cryptocurrency" => "BTC", "amount" => "0.1"})

      assert json_response(conn, 401)["error"] == "unauthenticated"
    end
  end
end
