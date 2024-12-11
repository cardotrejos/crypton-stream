defmodule CryptoStream.Services.PriceChangeMonitorTest do
  use CryptoStream.DataCase
  import Mox
  alias CryptoStream.Services.PriceChangeMonitor
  alias CryptoStream.Notifications

  setup :verify_on_exit!

  describe "price monitoring" do
    test "creates notification when price change exceeds threshold" do
      # Setup initial prices
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:ok, %{"bitcoin" => 50000.0, "ethereum" => 2000.0}}
      end)

      # Start the monitor
      start_supervised!({PriceChangeMonitor, price_client: CryptoStream.Services.MockCoingeckoClient})

      # Simulate price check after significant change
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:ok, %{"bitcoin" => 55000.0, "ethereum" => 2000.0}}
      end)

      # Trigger price check manually
      send(PriceChangeMonitor, :check_prices)
      Process.sleep(100) # Give time for async operations

      # Verify notification was created
      notifications = Notifications.list_notifications_by_type("price_change")
      assert length(notifications) == 1
      
      notification = List.first(notifications)
      assert notification.type == "price_change"
      assert notification.message =~ "bitcoin"
      assert notification.message =~ "10.0%"
      assert notification.metadata["coin"] == "bitcoin"
      assert notification.metadata["old_price"] == 50000.0
      assert notification.metadata["new_price"] == 55000.0
    end

    test "doesn't create notification for small price changes" do
      # Setup initial prices
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:ok, %{"bitcoin" => 50000.0}}
      end)

      # Start the monitor
      start_supervised!({PriceChangeMonitor, price_client: CryptoStream.Services.MockCoingeckoClient})

      # Simulate price check with small change
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:ok, %{"bitcoin" => 51000.0}}
      end)

      # Trigger price check manually
      send(PriceChangeMonitor, :check_prices)
      Process.sleep(100) # Give time for async operations

      # Verify no notification was created
      assert Notifications.list_notifications_by_type("price_change") == []
    end

    test "handles errors from price client" do
      expect(CryptoStream.Services.MockCoingeckoClient, :get_prices, fn ->
        {:error, "API error"}
      end)

      # Start the monitor
      {:ok, pid} = start_supervised({PriceChangeMonitor, price_client: CryptoStream.Services.MockCoingeckoClient})

      # Verify the process stays alive after error
      send(pid, :check_prices)
      Process.sleep(100)
      assert Process.alive?(pid)
    end
  end
end
