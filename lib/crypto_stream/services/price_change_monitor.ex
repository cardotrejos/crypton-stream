defmodule CryptoStream.Services.PriceChangeMonitor do
  @moduledoc """
  Service to monitor cryptocurrency price changes and trigger notifications
  for significant changes.
  """
  use GenServer
  require Logger
  alias CryptoStream.Services.PriceClient
  alias CryptoStream.Notifications
  alias CryptoStreamWeb.NotificationChannel

  @check_interval :timer.minutes(5)  # Poll every 5 minutes
  @significant_change_threshold 0.05 # 5% change threshold

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    price_client = Keyword.get(opts, :price_client, Application.get_env(:crypto_stream, :coingecko_client))
    schedule_check()
    {:ok, %{price_client: price_client, last_prices: %{}}}
  end

  @impl true
  def handle_info(:check_prices, %{price_client: client, last_prices: last_prices} = state) do
    case client.get_prices() do
      {:ok, current_prices} ->
        check_significant_changes(last_prices, current_prices)
        schedule_check()
        {:noreply, %{state | last_prices: current_prices}}

      {:error, reason} ->
        Logger.error("Failed to fetch prices: #{reason}")
        schedule_check()
        {:noreply, state}
    end
  end

  defp check_significant_changes(last_prices, current_prices) do
    current_prices
    |> Map.keys()
    |> Enum.each(fn coin ->
      with last_price when not is_nil(last_price) <- Map.get(last_prices, coin),
           current_price when not is_nil(current_price) <- Map.get(current_prices, coin) do
        percent_change = abs(current_price - last_price) / last_price

        if percent_change >= @significant_change_threshold do
          notify_price_change(coin, last_price, current_price, percent_change)
        end
      end
    end)
  end

  defp notify_price_change(coin, old_price, new_price, percent_change) do
    direction = if new_price > old_price, do: "increased", else: "decreased"
    message = "#{coin} price has #{direction} by #{Float.round(percent_change * 100, 2)}% " <>
              "(from $#{Float.round(old_price, 2)} to $#{Float.round(new_price, 2)})"
    
    {:ok, notification} = Notifications.create_notification(%{
      type: "price_change",
      message: message,
      metadata: %{
        coin: coin,
        old_price: old_price,
        new_price: new_price,
        percent_change: percent_change
      }
    })

    NotificationChannel.broadcast_notification(notification)
  end

  defp schedule_check do
    Process.send_after(self(), :check_prices, @check_interval)
  end
end
