defmodule CryptoStream.NotificationsTest do
  use CryptoStream.DataCase

  alias CryptoStream.Notifications

  describe "notifications" do
    @valid_attrs %{
      type: "price_change",
      message: "Bitcoin price increased by 10%",
      metadata: %{coin: "bitcoin", old_price: 50000.0, new_price: 55000.0}
    }
    @invalid_attrs %{type: nil, message: nil}

    test "create_notification/1 with valid data creates a notification" do
      assert {:ok, notification} = Notifications.create_notification(@valid_attrs)
      assert notification.type == "price_change"
      assert notification.message == "Bitcoin price increased by 10%"
      assert notification.metadata["coin"] == "bitcoin"
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "list_notifications/0 returns all notifications" do
      {:ok, notification} = Notifications.create_notification(@valid_attrs)
      assert [returned_notification] = Notifications.list_notifications()
      assert returned_notification.id == notification.id
    end

    test "list_notifications_by_type/1 returns notifications of specified type" do
      {:ok, notification} = Notifications.create_notification(@valid_attrs)
      {:ok, _other} = Notifications.create_notification(%{type: "other", message: "test"})
      
      assert [returned_notification] = Notifications.list_notifications_by_type("price_change")
      assert returned_notification.id == notification.id
    end

    test "get_notification!/1 returns the notification with given id" do
      {:ok, notification} = Notifications.create_notification(@valid_attrs)
      assert Notifications.get_notification!(notification.id).id == notification.id
    end
  end
end
