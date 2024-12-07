defmodule CryptoStreamWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Server}
  alias CryptoStreamWeb.Endpoint
  alias CryptoStreamWeb.Schemas.Market.{PriceResponse, HistoricalPriceResponse}
  alias CryptoStreamWeb.Schemas.User.{UserRequest, UserResponse, LoginRequest, ErrorResponse}

  @behaviour OpenApi

  @impl OpenApi
  @spec spec() :: OpenApi.t()
  def spec do
    %OpenApi{
      servers: [
        Server.from_endpoint(Endpoint)
      ],
      info: %Info{
        title: "CryptoStream API",
        version: "1.0"
      },
      paths: paths(),
      components: %Components{
        schemas: %{
          UserRequest: UserRequest,
          UserResponse: UserResponse,
          LoginRequest: LoginRequest,
          ErrorResponse: ErrorResponse,
          PriceResponse: PriceResponse,
          HistoricalPriceResponse: HistoricalPriceResponse
        }
      }
    }
    |> OpenApiSpex.resolve_schema_modules()
  end

  defp paths do
    %{
      "/api/register" => %OpenApiSpex.PathItem{
        post: %OpenApiSpex.Operation{
          tags: ["Authentication"],
          summary: "Register a new user",
          description: "Register a new user with email and password",
          operationId: "AuthController.register",
          requestBody: request_body("Request body for user registration", UserRequest),
          responses: %{
            201 => response("User registration successful", UserResponse),
            422 => response("Validation errors", ErrorResponse)
          }
        }
      },
      "/api/login" => %OpenApiSpex.PathItem{
        post: %OpenApiSpex.Operation{
          tags: ["Authentication"],
          summary: "Login user",
          description: "Login with email and password to receive JWT token",
          operationId: "AuthController.login",
          requestBody: request_body("Request body for user login", LoginRequest),
          responses: %{
            200 => response("Login successful", UserResponse),
            401 => response("Invalid credentials", ErrorResponse)
          }
        }
      },
      "/api/prices" => %OpenApiSpex.PathItem{
        get: %OpenApiSpex.Operation{
          tags: ["Market Data"],
          summary: "Get current prices",
          description: "Get current USD prices for supported cryptocurrencies (BTC, SOL)",
          operationId: "MarketController.get_prices",
          responses: %{
            200 => response("Current prices", PriceResponse),
            500 => response("Server error", ErrorResponse)
          }
        }
      },
      "/api/historical/{coin_id}" => %OpenApiSpex.PathItem{
        get: %OpenApiSpex.Operation{
          tags: ["Market Data"],
          summary: "Get historical prices",
          description: "Get historical USD prices for a specific cryptocurrency",
          operationId: "MarketController.get_historical_prices",
          parameters: [
            %OpenApiSpex.Parameter{
              in: :path,
              name: :coin_id,
              description: "Cryptocurrency ID (bitcoin or solana)",
              required: true,
              schema: %OpenApiSpex.Schema{type: :string, enum: ["bitcoin", "solana"]}
            },
            %OpenApiSpex.Parameter{
              in: :query,
              name: :range,
              description: "Predefined range (24h, 7d, 30d, 90d, 1y). If specified, from and to dates are ignored.",
              required: false,
              schema: %OpenApiSpex.Schema{type: :string, enum: ["24h", "7d", "30d", "90d", "1y"]}
            },
            %OpenApiSpex.Parameter{
              in: :query,
              name: :from,
              description: "Start date in ISO 8601 format (e.g., 2024-01-01T00:00:00Z). Required if range is not specified.",
              required: false,
              schema: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
            },
            %OpenApiSpex.Parameter{
              in: :query,
              name: :to,
              description: "End date in ISO 8601 format (e.g., 2024-01-02T00:00:00Z). Required if range is not specified.",
              required: false,
              schema: %OpenApiSpex.Schema{type: :string, format: :"date-time"}
            }
          ],
          responses: %{
            200 => response("Historical prices", HistoricalPriceResponse),
            400 => response("Bad request", ErrorResponse),
            500 => response("Server error", ErrorResponse)
          }
        }
      }
    }
  end

  defp request_body(description, schema) do
    %OpenApiSpex.RequestBody{
      description: description,
      required: true,
      content: %{
        "application/json" => %OpenApiSpex.MediaType{
          schema: schema
        }
      }
    }
  end

  defp response(description, schema) do
    %OpenApiSpex.Response{
      description: description,
      content: %{
        "application/json" => %OpenApiSpex.MediaType{
          schema: schema
        }
      }
    }
  end
end
