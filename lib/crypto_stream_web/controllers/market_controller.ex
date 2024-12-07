defmodule CryptoStreamWeb.MarketController do
  use CryptoStreamWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias CryptoStream.Services.CoingeckoClient
  alias CryptoStream.Utils.DateUtils
  alias OpenApiSpex.Schema

  def init(action) when action in [:get_prices, :get_historical_prices] do
    action
  end

  operation :get_prices,
    summary: "Get current prices",
    description: "Get current USD prices for supported cryptocurrencies",
    responses: [
      ok: {"Price response", "application/json", %Schema{
        type: :object,
        properties: %{
          bitcoin: %Schema{type: :object, properties: %{usd: %Schema{type: :number}}},
          solana: %Schema{type: :object, properties: %{usd: %Schema{type: :number}}}
        }
      }}
    ]

  def get_prices(conn, _params) do
    case CoingeckoClient.get_prices() do
      {:ok, prices} ->
        json(conn, prices)

      {:error, message} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: message})
    end
  end

  operation :get_historical_prices,
    summary: "Get historical prices",
    description: "Get historical USD prices for a specific cryptocurrency. You can either specify a predefined range or custom dates.",
    parameters: [
      coin_id: [
        in: :path,
        description: "Cryptocurrency ID (bitcoin or solana)",
        type: :string,
        required: true
      ],
      range: [
        in: :query,
        description: "Predefined range (24h, 7d, 30d, 90d, 1y). If specified, from and to dates are ignored.",
        type: :string,
        required: false
      ],
      from: [
        in: :query,
        description: "Start date in ISO 8601 format (e.g., 2024-01-01T00:00:00Z). Required if range is not specified.",
        type: :string,
        required: false
      ],
      to: [
        in: :query,
        description: "End date in ISO 8601 format (e.g., 2024-01-02T00:00:00Z). Required if range is not specified.",
        type: :string,
        required: false
      ]
    ],
    responses: [
      ok: {"Historical price response", "application/json", %Schema{
        type: :object,
        properties: %{
          prices: %Schema{
            type: :array,
            items: %Schema{
              type: :object,
              properties: %{
                date: %Schema{type: :string, format: :"date-time"},
                price: %Schema{type: :number}
              }
            }
          },
          range: %Schema{type: :string, description: "The range used for the query"}
        }
      }}
    ]

  def get_historical_prices(conn, %{"coin_id" => coin_id, "range" => range}) when not is_nil(range) do
    with true <- CoingeckoClient.supported_coin?(coin_id),
         {:ok, {from_unix, to_unix}} <- DateUtils.get_date_range(range),
         {:ok, data} <- CoingeckoClient.get_historical_prices(coin_id, from_unix, to_unix) do
      formatted_data = 
        data
        |> DateUtils.format_price_data()
        |> Map.put("range", range)
      
      json(conn, formatted_data)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Unsupported cryptocurrency"})

      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end

  def get_historical_prices(conn, %{"coin_id" => coin_id, "from" => from, "to" => to}) do
    with true <- CoingeckoClient.supported_coin?(coin_id),
         {:ok, from_unix} <- DateUtils.iso_to_unix(from),
         {:ok, to_unix} <- DateUtils.iso_to_unix(to),
         {:ok, data} <- CoingeckoClient.get_historical_prices(coin_id, from_unix, to_unix) do
      formatted_data = 
        data
        |> DateUtils.format_price_data()
        |> Map.put("range", "custom")
      
      json(conn, formatted_data)
    else
      false ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Unsupported cryptocurrency"})

      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: message})
    end
  end

  def get_historical_prices(conn, %{"coin_id" => _coin_id}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Missing date parameters. Either specify 'range' or both 'from' and 'to' dates",
      valid_ranges: DateUtils.valid_ranges()
    })
  end
end
