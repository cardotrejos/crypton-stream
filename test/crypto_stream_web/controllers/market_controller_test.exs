defmodule CryptoStreamWeb.MarketControllerTest do
  use CryptoStreamWeb.ConnCase
  import Mox

  setup :verify_on_exit!

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET /api/prices" do
    test "returns current prices when successful", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:ok, %{
          "bitcoin" => %{"usd" => 45000.50},
          "solana" => %{"usd" => 100.25}
        }}
      end)

      conn = get(conn, ~p"/api/prices")
      assert json_response(conn, 200) == %{
        "bitcoin" => %{"usd" => 45000.50},
        "solana" => %{"usd" => 100.25}
      }
    end

    test "returns error when API fails", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:error, "API request failed"}
      end)

      conn = get(conn, ~p"/api/prices")
      assert json_response(conn, 500) == %{"error" => "API request failed"}
    end
  end

  describe "GET /api/historical/:coin_id" do
    test "returns historical prices with range parameter", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :supported_coin?, fn "bitcoin" -> true end)
      expect(CryptoStream.Services.MockCoingeckoClient, :get_historical_prices, fn "bitcoin", _, _ ->
        {:ok, %{
          "prices" => [
            [1609459200000, 29000.50],
            [1609545600000, 29500.75]
          ]
        }}
      end)

      conn = get(conn, ~p"/api/historical/bitcoin?range=24h")
      response = json_response(conn, 200)
      assert response["prices"]
      assert response["range"] == "24h"
    end

    test "returns historical prices with custom dates", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :supported_coin?, fn "bitcoin" -> true end)
      expect(CryptoStream.Services.MockCoingeckoClient, :get_historical_prices, fn "bitcoin", _, _ ->
        {:ok, %{
          "prices" => [
            [1609459200000, 29000.50],
            [1609545600000, 29500.75]
          ]
        }}
      end)

      conn = get(conn, ~p"/api/historical/bitcoin?from=2024-01-01T00:00:00Z&to=2024-01-02T00:00:00Z")
      response = json_response(conn, 200)
      assert response["prices"]
      assert response["range"] == "custom"
    end

    test "returns error for invalid coin", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :supported_coin?, fn "invalid" -> false end)
      expect(CryptoStream.Services.MockCoingeckoClient, :get_historical_prices, fn "invalid", _from, _to ->
        {:error, "Unsupported cryptocurrency: invalid"}
      end)

      conn = get(conn, ~p"/api/historical/invalid?range=24h")
      assert json_response(conn, 400) == %{"error" => "Unsupported cryptocurrency"}
    end

    test "returns error for missing parameters", %{conn: conn} do
      conn = get(conn, ~p"/api/historical/bitcoin")
      response = json_response(conn, 400)
      assert response["error"] =~ "Missing date parameters"
      assert is_list(response["valid_ranges"])
    end

    test "returns error for historical prices API failure", %{conn: conn} do
      expect(CryptoStream.Services.MockCoingeckoClient, :supported_coin?, fn "bitcoin" -> true end)
      expect(CryptoStream.Services.MockCoingeckoClient, :get_historical_prices, fn "bitcoin", _, _ ->
        {:error, "API request failed"}
      end)

      conn = get(conn, ~p"/api/historical/bitcoin?range=24h")
      assert json_response(conn, 500) == %{"error" => "API request failed"}
    end
  end
end
