defmodule CryptoStreamWeb.NotificationController do
  use CryptoStreamWeb, :controller
  alias CryptoStream.Notifications
  alias Phoenix.PubSub

  def index(conn, _params) do
    conn =
      conn
      |> put_resp_content_type("text/event-stream")
      |> put_resp_header("cache-control", "no-cache")
      |> put_resp_header("connection", "keep-alive")
      |> send_chunked(200)

    PubSub.subscribe(CryptoStream.PubSub, "notifications:lobby")

    # Send initial notifications
    notifications = Notifications.list_notifications()
    Enum.each(notifications, &send_notification(conn, &1))

    # Keep the connection alive
    receive_loop(conn)
  end

  defp receive_loop(conn) do
    receive do
      {:new_notification, notification} ->
        case send_notification(conn, notification) do
          {:ok, conn} -> receive_loop(conn)
          {:error, :closed} -> conn
        end
    end
  end

  defp send_notification(conn, notification) do
    data = Jason.encode!(%{
      id: notification.id,
      type: notification.type,
      message: notification.message,
      metadata: notification.metadata,
      inserted_at: notification.inserted_at
    })

    chunk(conn, "event: notification\ndata: #{data}\n\n")
  end
end
