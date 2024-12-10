defmodule CryptoStream.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :type, :string, null: false
      add :cryptocurrency, :string, null: false
      add :amount_crypto, :decimal, null: false
      add :price_usd, :decimal, null: false
      add :total_usd, :decimal, null: false
      add :account_id, references(:accounts, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:transactions, [:account_id])
  end
end
