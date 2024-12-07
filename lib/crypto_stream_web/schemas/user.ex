defmodule CryptoStreamWeb.Schemas.User do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  defmodule UserRequest do
    OpenApiSpex.schema(%{
      title: "UserRequest",
      description: "Request body for user registration",
      type: :object,
      properties: %{
        email: %Schema{type: :string, format: :email, description: "User email"},
        password: %Schema{type: :string, description: "User password", minLength: 6}
      },
      required: [:email, :password],
      example: %{
        "email" => "user@example.com",
        "password" => "secret123"
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
end
