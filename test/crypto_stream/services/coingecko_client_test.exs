defmodule CryptoStream.Services.CoingeckoClientTest do
  use ExUnit.Case, async: true
  alias CryptoStream.Services.CoingeckoClient

  setup do
    bypass = Bypass.open()
    Application.put_env(:crypto_stream, :coingecko_base_url, "http://localhost:#{bypass.port}")
    {:ok, bypass: bypass}
  end

  describe "get_prices/0" do
    test "returns current prices when successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/simple/price", fn conn ->
        assert conn.query_string =~ "ids=bitcoin,solana"
        assert conn.query_string =~ "vs_currencies=usd"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, ~s({
          "bitcoin": {"usd": 45000.50},
          "solana": {"usd": 100.25}
        }))
      end)

      assert {:ok, prices} = CoingeckoClient.get_prices()
      assert prices["bitcoin"]["usd"] == 45000.50
      assert prices["solana"]["usd"] == 100.25
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/simple/price", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      assert {:error, message} = CoingeckoClient.get_prices()
      assert message =~ "API request failed with status 500"
    end

    test "returns error on parse failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/simple/price", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, "invalid json")
      end)

      assert {:error, message} = CoingeckoClient.get_prices()
      assert message =~ "Failed to parse response"
    end
  end

  describe "get_historical_prices/3" do
    test "returns historical prices when successful", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/coins/bitcoin/market_chart/range", fn conn ->
        assert conn.query_string =~ "vs_currency=usd"
        assert conn.query_string =~ "from="
        assert conn.query_string =~ "to="

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, ~s({
          "prices": [
            [1609459200000, 29000.50],
            [1609545600000, 29500.75]
          ]
        }))
      end)

      from_date = DateTime.from_unix!(1609459200)
      to_date = DateTime.from_unix!(1609545600)

      assert {:ok, data} = CoingeckoClient.get_historical_prices("bitcoin", from_date, to_date)
      assert length(data["prices"]) == 2
      assert Enum.at(data["prices"], 0) |> Enum.at(1) == 29000.50
    end

    test "returns error for unsupported coin", %{bypass: _bypass} do
      from_date = DateTime.from_unix!(1609459200)
      to_date = DateTime.from_unix!(1609545600)

      assert {:error, message} = CoingeckoClient.get_historical_prices("dogecoin", from_date, to_date)
      assert message =~ "Unsupported cryptocurrency"
    end

    test "returns error on API failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/coins/bitcoin/market_chart/range", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      from_date = DateTime.from_unix!(1609459200)
      to_date = DateTime.from_unix!(1609545600)

      assert {:error, message} = CoingeckoClient.get_historical_prices("bitcoin", from_date, to_date)
      assert message =~ "API request failed with status 500"
    end

    test "returns error on parse failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/coins/bitcoin/market_chart/range", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, "invalid json")
      end)

      from_date = DateTime.from_unix!(1609459200)
      to_date = DateTime.from_unix!(1609545600)

      assert {:error, message} = CoingeckoClient.get_historical_prices("bitcoin", from_date, to_date)
      assert message =~ "Failed to parse response"
    end
  end

  describe "supported_coin?/1" do
    test "returns true for supported coins" do
      assert CoingeckoClient.supported_coin?("bitcoin")
      assert CoingeckoClient.supported_coin?("solana")
    end

    test "returns false for unsupported coins" do
      refute CoingeckoClient.supported_coin?("dogecoin")
      refute CoingeckoClient.supported_coin?("invalid")
    end
  end
end
