defmodule CryptoStreamWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Server}
  alias CryptoStreamWeb.Endpoint
  alias CryptoStreamWeb.Schemas.{User, UserRequest, UserResponse, LoginRequest, ErrorResponse}

  @behaviour OpenApi

  @impl OpenApi
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
          User: User,
          UserRequest: UserRequest,
          UserResponse: UserResponse,
          LoginRequest: LoginRequest,
          ErrorResponse: ErrorResponse
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
