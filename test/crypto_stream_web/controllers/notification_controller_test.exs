defmodule CryptoStreamWeb.NotificationControllerTest do
  use CryptoStreamWeb.ConnCase
  alias CryptoStream.Notifications
  alias CryptoStreamWeb.NotificationChannel

  describe "SSE notifications" do
    test "streams notifications", %{conn: conn} do
      # Create a notification
      {:ok, notification} = Notifications.create_notification(%{
        type: "test",
        message: "Test notification",
        metadata: %{test: true}
      })

      # Start streaming
      conn = get(build_conn(), "/api/notifications/stream")
      
      # Verify SSE headers
      assert get_resp_header(conn, "content-type") == ["text/event-stream; charset=utf-8"]
      assert get_resp_header(conn, "cache-control") == ["no-cache"]
      assert get_resp_header(conn, "connection") == ["keep-alive"]

      # Broadcast a new notification
      NotificationChannel.broadcast_notification(notification)

      # The actual streaming test would require integration testing
      # as it involves long-lived connections
    end
  end
end
