defmodule CryptoStream.Repo.Migrations.RemoveTotalUsdFromTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      remove :total_usd
    end
  end
end
