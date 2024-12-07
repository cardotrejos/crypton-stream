defmodule CryptoStreamWeb.Schemas.Market do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule PriceResponse do
    OpenApiSpex.schema(%{
      title: "PriceResponse",
      description: "Current cryptocurrency prices",
      type: :object,
      properties: %{
        bitcoin: %Schema{
          type: :object,
          properties: %{
            usd: %Schema{type: :number, description: "Current price in USD"}
          }
        },
        solana: %Schema{
          type: :object,
          properties: %{
            usd: %Schema{type: :number, description: "Current price in USD"}
          }
        }
      },
      required: [:bitcoin, :solana],
      example: %{
        "bitcoin" => %{"usd" => 45000.50},
        "solana" => %{"usd" => 100.25}
      }
    })
  end

  defmodule HistoricalPriceResponse do
    OpenApiSpex.schema(%{
      title: "HistoricalPriceResponse",
      description: "Historical cryptocurrency prices",
      type: :object,
      properties: %{
        prices: %Schema{
          type: :array,
          items: %Schema{
            type: :object,
            properties: %{
              date: %Schema{type: :string, format: :"date-time", description: "Price timestamp"},
              price: %Schema{type: :number, description: "Price in USD"}
            }
          }
        },
        range: %Schema{type: :string, description: "Time range of the query"}
      },
      required: [:prices, :range],
      example: %{
        "prices" => [
          %{"date" => "2024-01-01T00:00:00Z", "price" => 45000.50},
          %{"date" => "2024-01-02T00:00:00Z", "price" => 46000.75}
        ],
        "range" => "24h"
      }
    })
  end
end
