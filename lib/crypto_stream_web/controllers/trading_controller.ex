defmodule CryptoStreamWeb.TradingController do
  use CryptoStreamWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CryptoStream.Trading
  alias CryptoStreamWeb.Schemas.Trading.TransactionResponse

  @price_client Application.compile_env(:crypto_stream, :coingecko_client, CryptoStream.Services.CoingeckoClient)

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
         {:ok, prices} <- @price_client.get_prices(),
         {:ok, price} <- extract_price(cryptocurrency, prices),
         {:ok, transaction} <- Trading.buy_cryptocurrency(account, cryptocurrency, decimal_amount, price) do
      conn
      |> put_status(:created)
      |> render(:transaction, %{transaction: transaction})
    else
      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "unauthorized", details: "User not authenticated"})

      {:error, :insufficient_balance} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{"errors" => %{"detail" => "Insufficient balance"}})

      {:error, message} when is_binary(message) ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_request", details: message})

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_request", details: "Invalid request"})
    end
  end

  def buy(conn, %{"cryptocurrency" => cryptocurrency, "amount" => amount}) do
    buy(conn, %{"cryptocurrency" => cryptocurrency, "amount_usd" => amount})
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

  defp extract_price("BTC", prices) do
    case get_in(prices, ["bitcoin", "usd"]) do
      nil -> {:error, "Price not found for BTC"}
      price -> {:ok, Decimal.new("#{price}")}
    end
  end

  defp extract_price("SOL", prices) do
    case get_in(prices, ["solana", "usd"]) do
      nil -> {:error, "Price not found for SOL"}
      price -> {:ok, Decimal.new("#{price}")}
    end
  end

  defp extract_price(crypto, _prices) do
    {:error, "Unsupported cryptocurrency: #{crypto}"}
  end
end
