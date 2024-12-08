defmodule CryptoStreamWeb.TradingController do
  use CryptoStreamWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CryptoStream.Trading
  alias CryptoStream.Services.MockCoingeckoClient
  alias CryptoStreamWeb.{ErrorJSON, Schemas.Trading.TransactionResponse}

  operation :buy,
    summary: "Buy cryptocurrency",
    tags: ["Trading"],
    description: "Buy cryptocurrency with USD from the user's account",
    request_body: {"Buy request", "application/json", %OpenApiSpex.Schema{
      type: :object,
      required: [:cryptocurrency, :amount_usd],
      properties: %{
        cryptocurrency: %OpenApiSpex.Schema{type: :string, description: "Cryptocurrency symbol"},
        amount_usd: %OpenApiSpex.Schema{type: :string, description: "Amount in USD to spend"}
      }
    }},
    responses: [
      created: {"Transaction response", "application/json", TransactionResponse},
      unprocessable_entity: {"Error", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          errors: %OpenApiSpex.Schema{type: :object}
        }
      }},
      unauthorized: {"Error", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          errors: %OpenApiSpex.Schema{type: :object}
        }
      }}
    ],
    security: [%{"bearer" => []}]

  def buy(conn, %{"cryptocurrency" => cryptocurrency, "amount_usd" => amount_usd}) do
    with {:ok, account} <- get_current_account(conn),
         {:ok, decimal_amount} <- parse_decimal(amount_usd),
         {:ok, price} <- MockCoingeckoClient.get_price(cryptocurrency, "usd"),
         {:ok, decimal_price} <- parse_decimal(price),
         {:ok, transaction} <- Trading.buy_cryptocurrency(account, cryptocurrency, decimal_amount, decimal_price) do
      conn
      |> put_status(:created)
      |> render(:transaction, %{transaction: transaction})
    else
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized", details: "User not authenticated"})
      {:error, :invalid_decimal} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, %{error: :invalid_request})
      {:error, :insufficient_balance} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, %{error: :insufficient_balance})
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, %{error: :invalid_request})
    end
  end

  operation :list_transactions,
    summary: "List transactions",
    tags: ["Trading"],
    description: "List all transactions for the authenticated user",
    responses: [
      ok: {"Transaction list response", "application/json", %OpenApiSpex.Schema{
        type: :array,
        items: TransactionResponse
      }},
      unauthorized: {"Error", "application/json", %OpenApiSpex.Schema{
        type: :object,
        properties: %{
          errors: %OpenApiSpex.Schema{type: :object}
        }
      }}
    ],
    security: [%{"bearer" => []}]

  def list_transactions(conn, _params) do
    with {:ok, account} <- get_current_account(conn),
         transactions <- Trading.list_account_transactions(account) do
      render(conn, :transactions, %{transactions: transactions})
    else
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized", details: "User not authenticated"})
    end
  end

  # Private helper functions

  defp get_current_account(conn) do
    case Guardian.Plug.current_resource(conn) do
      nil -> {:error, :unauthorized}
      user ->
        case user.account do
          nil -> {:error, :unauthorized}
          account -> {:ok, account}
        end
    end
  end

  defp parse_decimal(value) do
    try do
      {:ok, Decimal.new(value)}
    rescue
      Decimal.Error -> {:error, :invalid_decimal}
    end
  end
end
