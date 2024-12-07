defmodule CryptoStreamWeb.MarketController do
  use CryptoStreamWeb, :controller

  @coingecko_client Application.compile_env(:crypto_stream, :coingecko_client)

  def get_prices(conn, _params) do
    case @coingecko_client.get_prices() do
      {:ok, prices} -> json(conn, prices)
      {:error, message} -> conn |> put_status(500) |> json(%{error: message})
    end
  end

  def get_historical_prices(conn, %{"coin_id" => coin_id, "range" => range}) do
    unless @coingecko_client.supported_coin?(coin_id) do
      conn
      |> put_status(400)
      |> json(%{error: "Unsupported cryptocurrency"})
      |> halt()
    end

    case parse_time_range(range) do
      {:ok, from_date, to_date} ->
        case @coingecko_client.get_historical_prices(coin_id, from_date, to_date) do
          {:ok, data} -> 
            json(conn, Map.put(data, "range", range))
          {:error, "Unsupported cryptocurrency" <> _} ->
            conn |> put_status(400) |> json(%{error: "Unsupported cryptocurrency"})
          {:error, message} -> 
            conn |> put_status(500) |> json(%{error: message})
        end
      :error ->
        conn |> put_status(400) |> json(%{error: "Invalid time range"})
    end
  end

  def get_historical_prices(conn, %{"coin_id" => coin_id, "from" => from, "to" => to}) do
    unless @coingecko_client.supported_coin?(coin_id) do
      conn
      |> put_status(400)
      |> json(%{error: "Unsupported cryptocurrency"})
      |> halt()
    end

    with {:ok, from_date, _} <- DateTime.from_iso8601(from),
         {:ok, to_date, _} <- DateTime.from_iso8601(to) do
      case @coingecko_client.get_historical_prices(coin_id, from_date, to_date) do
        {:ok, data} -> 
          json(conn, Map.put(data, "range", "custom"))
        {:error, "Unsupported cryptocurrency" <> _} ->
          conn |> put_status(400) |> json(%{error: "Unsupported cryptocurrency"})
        {:error, message} -> 
          conn |> put_status(500) |> json(%{error: message})
      end
    else
      _ -> conn |> put_status(400) |> json(%{error: "Invalid date format"})
    end
  end

  def get_historical_prices(conn, _params) do
    valid_ranges = ["24h", "7d", "30d"]
    conn 
    |> put_status(400) 
    |> json(%{
      error: "Missing date parameters",
      valid_ranges: valid_ranges
    })
  end

  defp parse_time_range("24h") do
    now = DateTime.utc_now()
    {:ok, DateTime.add(now, -24, :hour), now}
  end

  defp parse_time_range("7d") do
    now = DateTime.utc_now()
    {:ok, DateTime.add(now, -7, :day), now}
  end

  defp parse_time_range("30d") do
    now = DateTime.utc_now()
    {:ok, DateTime.add(now, -30, :day), now}
  end

  defp parse_time_range(_), do: :error
end
