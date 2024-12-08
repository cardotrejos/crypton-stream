defmodule CryptoStream.Repo.Migrations.AddAmountUsdToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :amount_usd, :decimal, precision: 20, scale: 8, null: false
      remove :amount_crypto, :decimal
    end
  end
end
