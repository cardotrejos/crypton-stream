defmodule CryptoStream.Repo.Migrations.AddAmountCryptoToTransactions do
  use Ecto.Migration
  import Ecto.Query

  def up do
    # First add the column as nullable
    alter table(:transactions) do
      add :amount_crypto, :decimal, null: true
    end

    # Update existing records
    execute """
    UPDATE transactions
    SET amount_crypto = amount_usd / price_usd
    WHERE amount_crypto IS NULL
    """

    # Make the column non-nullable
    alter table(:transactions) do
      modify :amount_crypto, :decimal, null: false
    end
  end

  def down do
    alter table(:transactions) do
      remove :amount_crypto
    end
  end
end
