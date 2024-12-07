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

  defmodule LoginRequest do
    OpenApiSpex.schema(%{
      title: "LoginRequest",
      description: "POST body for logging in",
      type: :object,
      properties: %{
        email: %Schema{type: :string, description: "User email", format: :email},
        password: %Schema{type: :string, description: "User password"}
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
      description: "Response schema for single user",
      type: :object,
      properties: %{
        data: %Schema{
          type: :object,
          properties: %{
            id: %Schema{type: :integer, description: "User ID"},
            email: %Schema{type: :string, description: "User email"},
            username: %Schema{type: :string, description: "Username"},
            token: %Schema{type: :string, description: "JWT token"}
          }
        }
      },
      required: [:data],
      example: %{
        "data" => %{
          "id" => 123,
          "email" => "user@example.com",
          "username" => "johndoe",
          "token" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        }
      }
    })
  end

  defmodule ErrorResponse do
    OpenApiSpex.schema(%{
      title: "ErrorResponse",
      description: "Response schema for errors",
      type: :object,
      properties: %{
        errors: %Schema{
          type: :object,
          additionalProperties: %Schema{
            type: :array,
            items: %Schema{type: :string}
          }
        }
      },
      required: [:errors],
      example: %{
        "errors" => %{
          "email" => ["has already been taken"],
          "password" => ["can't be blank"]
        }
      }
    })
  end
end
