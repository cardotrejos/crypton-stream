defmodule CryptoStream.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :balance_usd, :decimal, null: false, default: 10000.00
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:accounts, [:user_id])
  end
end
