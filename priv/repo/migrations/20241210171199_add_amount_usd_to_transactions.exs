defmodule CryptoStream.Repo.Migrations.AddAmountUsdToTransactions do
  use Ecto.Migration

  def change do
    # First add the column as nullable
    alter table(:transactions) do
      add :amount_usd, :decimal, precision: 20, scale: 8, null: true
    end

    # Update existing records to calculate amount_usd from amount_crypto and price_usd
    execute """
    UPDATE transactions 
    SET amount_usd = amount_crypto * price_usd 
    WHERE amount_usd IS NULL
    """

    # Now make the column non-nullable and remove the old column
    alter table(:transactions) do
      modify :amount_usd, :decimal, precision: 20, scale: 8, null: false
      remove :amount_crypto, :decimal
    end
  end
end
