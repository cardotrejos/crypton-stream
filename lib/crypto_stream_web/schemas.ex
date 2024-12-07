defmodule CryptoStreamWeb.Schemas do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule User do
    OpenApiSpex.schema(%{
      title: "User",
      description: "A user of the application",
      type: :object,
      properties: %{
        id: %Schema{type: :integer, description: "User ID"},
        email: %Schema{type: :string, description: "User email", format: :email},
        username: %Schema{type: :string, description: "Username"},
        token: %Schema{type: :string, description: "JWT token"}
      },
      required: [:email, :username],
      example: %{
        "id" => 123,
        "email" => "user@example.com",
        "username" => "johndoe",
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }
    })
  end

  defmodule UserRequest do
    OpenApiSpex.schema(%{
      title: "UserRequest",
      description: "POST body for creating a user",
      type: :object,
      properties: %{
        user: %Schema{
          type: :object,
          properties: %{
            email: %Schema{type: :string, description: "User email", format: :email},
            password: %Schema{type: :string, description: "User password", minLength: 6},
            username: %Schema{type: :string, description: "Username"}
          },
          required: [:email, :password, :username]
        }
      },
      required: [:user],
      example: %{
        "user" => %{
          "email" => "user@example.com",
          "password" => "secret123",
          "username" => "johndoe"
        }
      }
    })
  end

  defmodule UserResponse do
    OpenApiSpex.schema(%{
      title: "UserResponse",
      description: "Response schema for user operations",
      type: :object,
      properties: %{
        id: %Schema{type: :string, format: :uuid, description: "User ID"},
        email: %Schema{type: :string, format: :email, description: "User email"},
        token: %Schema{type: :string, description: "JWT token"}
      },
      required: [:id, :email, :token],
      example: %{
        "id" => "123e4567-e89b-12d3-a456-426614174000",
        "email" => "user@example.com",
        "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
      }
    })
  end

  defmodule LoginRequest do
    OpenApiSpex.schema(%{
      title: "LoginRequest",
      description: "Request body for user login",
      type: :object,
      properties: %{
        email: %Schema{type: :string, format: :email, description: "User email"},
        password: %Schema{type: :string, description: "User password"}
      },
      required: [:email, :password],
      example: %{
        "email" => "user@example.com",
        "password" => "secret123"
      }
    })
  end

  defmodule ErrorResponse do
    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Error response",
      type: :object,
      properties: %{
        error: %Schema{type: :string, description: "Error message"}
      },
      required: [:error],
      example: %{
        "error" => "Invalid credentials"
      }
    })
  end

  defmodule Market.PriceResponse do
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

  defmodule Market.HistoricalPriceResponse do
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
