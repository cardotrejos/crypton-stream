defmodule CryptoStreamWeb.TradingController do
  use CryptoStreamWeb, :controller

  alias CryptoStream.Trading
  alias CryptoStream.Services.MockCoingeckoClient

  def buy(conn, %{"cryptocurrency" => cryptocurrency, "amount_usd" => amount_usd}) do
    account = conn.assigns.current_account

    with {:ok, decimal_amount} <- parse_decimal(amount_usd),
         {:ok, price} <- MockCoingeckoClient.get_price(cryptocurrency, "usd"),
         {:ok, decimal_price} <- parse_decimal(price),
         {:ok, transaction} <- Trading.buy_cryptocurrency(account, cryptocurrency, decimal_amount, decimal_price) do
      conn
      |> put_status(:created)
      |> render(:transaction, transaction: transaction)
    else
      {:error, :invalid_decimal} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", message: "Invalid request")
      {:error, :insufficient_balance} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", message: "Insufficient balance")
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: CryptoStreamWeb.ErrorJSON)
        |> render("error.json", message: "Invalid request")
    end
  end

  def list_transactions(conn, _params) do
    account = conn.assigns.current_account
    transactions = Trading.list_account_transactions(account)
    render(conn, :transactions, transactions: transactions)
  end

  defp parse_decimal(value) do
    try do
      {:ok, Decimal.new(value)}
    rescue
      Decimal.Error -> {:error, :invalid_decimal}
    end
  end
end
