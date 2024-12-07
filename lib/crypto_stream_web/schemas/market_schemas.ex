defmodule CryptoStreamWeb.Schemas.Market do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule PriceResponse do
    OpenApiSpex.schema(%{
      title: "PriceResponse",
      description: "Response with current cryptocurrency prices",
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
        "bitcoin" => %{"usd" => 43150.25},
        "solana" => %{"usd" => 95.75}
      }
    })
  end

  defmodule HistoricalPricePoint do
    OpenApiSpex.schema(%{
      title: "HistoricalPricePoint",
      description: "A single historical price point",
      type: :object,
      properties: %{
        date: %Schema{type: :string, format: :"date-time", description: "Timestamp of the price"},
        price: %Schema{type: :number, description: "Price in USD"}
      },
      required: [:date, :price],
      example: %{
        "date" => "2024-01-01T00:00:00Z",
        "price" => 43150.25
      }
    })
  end

  defmodule HistoricalPriceResponse do
    OpenApiSpex.schema(%{
      title: "HistoricalPriceResponse",
      description: "Response with historical cryptocurrency prices",
      type: :object,
      properties: %{
        prices: %Schema{
          type: :array,
          items: HistoricalPricePoint,
          description: "List of historical price points"
        },
        range: %Schema{
          type: :string,
          description: "The range used for the query (24h, 7d, 30d, 90d, 1y, or 'custom')"
        }
      },
      required: [:prices, :range],
      example: %{
        "prices" => [
          %{"date" => "2024-01-01T00:00:00Z", "price" => 43150.25},
          %{"date" => "2024-01-01T01:00:00Z", "price" => 43200.75}
        ],
        "range" => "24h"
      }
    })
  end
end
