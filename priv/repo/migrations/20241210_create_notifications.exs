defmodule CryptoStream.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :type, :string, null: false
      add :message, :text, null: false
      add :metadata, :map
      add :read_at, :utc_datetime

      timestamps()
    end

    create index(:notifications, [:type])
    create index(:notifications, [:inserted_at])
  end
end
