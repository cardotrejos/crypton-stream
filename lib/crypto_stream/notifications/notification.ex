defmodule CryptoStream.Notifications.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :type, :string
    field :message, :string
    field :metadata, :map
    field :read_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :message, :metadata, :read_at])
    |> validate_required([:type, :message])
  end
end
