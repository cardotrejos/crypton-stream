defmodule CryptoStreamWeb.TradingController do
  use CryptoStreamWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CryptoStream.Trading
  alias CryptoStreamWeb.Schemas.Trading.{BuyRequest, TransactionResponse}

  operation :buy,
    summary: "Buy cryptocurrency",
    tags: ["Trading"],
    description: "Simulated purchase of cryptocurrency using virtual USD balance",
    request_body: {"Buy request", "application/json", BuyRequest},
    responses: [
      ok: {"Transaction response", "application/json", TransactionResponse},
      unprocessable_entity: {"Error", "application/json", ErrorResponse}
    ],
    security: [%{"bearer" => []}]

  def buy(conn, %{"cryptocurrency" => crypto, "amount" => amount}) do
    with user when not is_nil(user) <- Guardian.Plug.current_resource(conn),
         account when not is_nil(account) <- user.account,
         {:ok, %{transaction: transaction, account: updated_account}} <- 
           Trading.buy_cryptocurrency(account.id, crypto, amount, "50000.00") do
      conn
      |> put_status(:ok)
      |> render(:transaction, transaction: transaction, account: updated_account)
    else
      nil -> 
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
      
      {:error, :insufficient_balance} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Insufficient balance"})

      {:error, :account_not_found} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Account not found"})

      {:error, :invalid_decimal} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid amount format"})

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to process transaction"})
    end
  end

  def buy(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "Invalid parameters. Required: cryptocurrency and amount"})
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
      unauthorized: {"Error", "application/json", ErrorResponse}
    ],
    security: [%{"bearer" => []}]

  def list_transactions(conn, _params) do
    case Guardian.Plug.current_resource(conn) do
      nil -> 
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Unauthorized"})
        
      user ->
        case user.account do
          nil ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Account not found"})
            
          account ->
            transactions = Trading.list_account_transactions(account.id)
            conn
            |> put_status(:ok)
            |> render(:transactions, transactions: transactions)
        end
    end
  end
end
