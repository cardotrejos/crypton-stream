defmodule CryptoStreamWeb.TradingController do
  use CryptoStreamWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CryptoStream.Trading
  alias CryptoStreamWeb.Schemas.Trading.TransactionResponse

  @price_client Application.compile_env(:crypto_stream, :coingecko_client, CryptoStream.Services.CoingeckoClient)

  operation :buy,
    summary: "Buy cryptocurrency",
    tags: ["Trading"],
    description: "Buy cryptocurrency with USD or crypto amount from the user's account",
    request_body: {"Buy request", "application/json", %OpenApiSpex.Schema{
      type: :object,
      oneOf: [
        %OpenApiSpex.Schema{
          type: :object,
          required: [:cryptocurrency, :amount_usd],
          properties: %{
            cryptocurrency: %OpenApiSpex.Schema{type: :string, description: "Cryptocurrency symbol"},
            amount_usd: %OpenApiSpex.Schema{type: :string, description: "Amount in USD to spend"}
          }
        },
        %OpenApiSpex.Schema{
          type: :object,
          required: [:cryptocurrency, :amount_crypto],
          properties: %{
            cryptocurrency: %OpenApiSpex.Schema{type: :string, description: "Cryptocurrency symbol"},
            amount_crypto: %OpenApiSpex.Schema{type: :string, description: "Amount of cryptocurrency to buy"}
          }
        },
      ]
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

  def buy(conn, %{"cryptocurrency" => cryptocurrency} = params) do
    cond do
      Map.has_key?(params, "amount_usd") and Map.has_key?(params, "amount_crypto") ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_request", details: "Cannot specify both USD and crypto amounts"})

      Map.has_key?(params, "amount_usd") ->
        buy_with_usd(conn, cryptocurrency, params["amount_usd"])

      Map.has_key?(params, "amount_crypto") ->
        buy_with_crypto(conn, cryptocurrency, params["amount_crypto"])

      Map.has_key?(params, "amount") ->
        case params["amount"] do
          amount when is_binary(amount) ->
            if String.contains?(amount, "$") do
              # If amount starts with $, treat as USD amount
              buy_with_usd(conn, cryptocurrency, String.replace(amount, "$", ""))
            else
              # Otherwise treat as crypto amount
              buy_with_crypto(conn, cryptocurrency, amount)
            end
          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "invalid_request", details: "Invalid amount format"})
        end

      true ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_request", details: "Amount is required"})
    end
  end

  def buy(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid_request", details: "Cryptocurrency is required"})
  end

  defp buy_with_usd(conn, cryptocurrency, amount_usd) do
    with {:ok, account} <- get_current_account(conn),
         {:ok, decimal_amount} <- parse_decimal(amount_usd),
         {:ok, prices} <- @price_client.get_prices(),
         {:ok, price} <- extract_price(cryptocurrency, prices),
         {:ok, transaction} <- Trading.buy_cryptocurrency_with_usd(account, cryptocurrency, decimal_amount, price) do
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

  defp buy_with_crypto(conn, cryptocurrency, amount_crypto) do
    with {:ok, account} <- get_current_account(conn),
         {:ok, decimal_amount} <- parse_decimal(amount_crypto),
         {:ok, prices} <- @price_client.get_prices(),
         {:ok, price} <- extract_price(cryptocurrency, prices),
         {:ok, transaction} <- Trading.buy_cryptocurrency_with_crypto(account, cryptocurrency, decimal_amount, price) do
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
