defmodule CryptoStream.Utils.DateUtils do
  @moduledoc """
  Utilities for handling date conversions and validations.
  """

  @valid_ranges ["24h", "7d", "30d", "90d", "1y"]

  @doc """
  Converts an ISO 8601 date string to Unix timestamp.
  Returns {:ok, timestamp} if successful, {:error, reason} otherwise.
  """
  def iso_to_unix(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _offset} ->
        {:ok, DateTime.to_unix(datetime)}
      {:error, reason} ->
        {:error, "Invalid date format: #{reason}"}
    end
  end

  @doc """
  Formats a Unix timestamp to ISO 8601 date string.
  """
  def unix_to_iso(unix_timestamp) when is_integer(unix_timestamp) do
    unix_timestamp
    |> DateTime.from_unix!()
    |> DateTime.to_iso8601()
  end

  @doc """
  Formats price data with human-readable timestamps.
  """
  def format_price_data(%{"prices" => prices} = data) do
    formatted_prices = Enum.map(prices, fn [timestamp, price] ->
      iso_date = 
        (timestamp / 1000)
        |> trunc()
        |> unix_to_iso()
      
      %{
        "date" => iso_date,
        "price" => price
      }
    end)

    Map.put(data, "prices", formatted_prices)
  end

  def format_price_data(data), do: data

  @doc """
  Gets the date range based on a predefined range string.
  Valid ranges are: 24h, 7d, 30d, 90d, 1y
  Returns {:ok, {from_unix, to_unix}} or {:error, reason}
  """
  def get_date_range("24h") do
    now = DateTime.utc_now()
    from = DateTime.add(now, -24, :hour)
    {:ok, {DateTime.to_unix(from), DateTime.to_unix(now)}}
  end

  def get_date_range("7d") do
    now = DateTime.utc_now()
    from = DateTime.add(now, -7, :day)
    {:ok, {DateTime.to_unix(from), DateTime.to_unix(now)}}
  end

  def get_date_range("30d") do
    now = DateTime.utc_now()
    from = DateTime.add(now, -30, :day)
    {:ok, {DateTime.to_unix(from), DateTime.to_unix(now)}}
  end

  def get_date_range("90d") do
    now = DateTime.utc_now()
    from = DateTime.add(now, -90, :day)
    {:ok, {DateTime.to_unix(from), DateTime.to_unix(now)}}
  end

  def get_date_range("1y") do
    now = DateTime.utc_now()
    from = DateTime.add(now, -365, :day)
    {:ok, {DateTime.to_unix(from), DateTime.to_unix(now)}}
  end

  def get_date_range(range) when range in @valid_ranges do
    get_date_range(range)
  end

  def get_date_range(_invalid_range) do
    {:error, "Invalid range. Valid ranges are: #{Enum.join(@valid_ranges, ", ")}"}
  end

  @doc """
  Returns list of valid date ranges
  """
  def valid_ranges, do: @valid_ranges
end
