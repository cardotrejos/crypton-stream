defmodule CryptoStreamWeb.NotificationChannel do
  use Phoenix.Channel
  alias CryptoStream.Notifications

  def join("notifications:lobby", _message, socket) do
    {:ok, socket}
  end

  def broadcast_notification(notification) do
    Phoenix.PubSub.broadcast(
      CryptoStream.PubSub,
      "notifications:lobby",
      {:new_notification, notification}
    )
  end
end
