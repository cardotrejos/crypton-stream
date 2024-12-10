defmodule CryptoStreamWeb.Schemas.Trading do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule BuyRequest do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "BuyRequest",
      description: "Request body for buying cryptocurrency",
      type: :object,
      properties: %{
        cryptocurrency: %Schema{type: :string, description: "Cryptocurrency symbol (BTC or SOL)", example: "BTC"},
        amount: %Schema{
          type: :string,
          description: """
          Amount to buy. Can be specified in two formats:
          1. Cryptocurrency amount (e.g. "0.5" for 0.5 BTC) - internally converts to USD using current price
          2. USD amount by adding 'usd' suffix (e.g. "100usd" to buy $100 worth of crypto)

          Note: The transaction will store both amount_crypto and amount_usd fields, but the request only needs one format.
          """,
          example: "0.5"
        }
      },
      required: [:cryptocurrency, :amount]
    })
  end

  defmodule TransactionResponse do
    require OpenApiSpex

    OpenApiSpex.schema(%{
      title: "TransactionResponse",
      description: "Response for a successful transaction",
      type: :object,
      properties: %{
        transaction: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :integer, description: "Transaction ID"},
            type: %Schema{type: :string, description: "Transaction type (buy/sell)"},
            cryptocurrency: %Schema{type: :string, description: "Cryptocurrency symbol"},
            amount_crypto: %Schema{type: :string, description: "Amount of cryptocurrency"},
            price_usd: %Schema{type: :string, description: "Price per unit in USD"},
            total_usd: %Schema{type: :string, description: "Total transaction value in USD"},
            inserted_at: %Schema{type: :string, description: "Transaction timestamp"}
          }
        },
        account: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :integer, description: "Account ID"},
            balance_usd: %Schema{type: :string, description: "Updated account balance in USD"}
          }
        }
      },
      required: [:transaction, :account]
    })
  end
end
