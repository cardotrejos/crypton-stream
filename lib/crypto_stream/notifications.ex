defmodule CryptoStream.Notifications do
  @moduledoc """
  The Notifications context handles creation and management of system notifications.
  """
  
  alias CryptoStream.Repo
  alias CryptoStream.Notifications.Notification
  import Ecto.Query

  @doc """
  Creates a notification.
  """
  def create_notification(attrs \\ %{}) do
    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of notifications.
  """
  def list_notifications do
    Notification
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns notifications of a specific type.
  """
  def list_notifications_by_type(type) do
    Notification
    |> where([n], n.type == ^type)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single notification.
  """
  def get_notification!(id), do: Repo.get!(Notification, id)
end
