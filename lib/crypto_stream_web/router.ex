defmodule CryptoStreamWeb.Router do
  use CryptoStreamWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: CryptoStreamWeb.ApiSpec
  end

  pipeline :auth do
    plug CryptoStream.Guardian.AuthPipeline
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/api" do
    pipe_through :api
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI,
      path: "/api/openapi",
      swagger_ui_config: %{
        "deepLinking" => true,
        "persistAuthorization" => true,
        "displayOperationId" => false
      }
  end

  scope "/api" do
    pipe_through :api
    get "/openapi", OpenApiSpex.Plug.RenderSpec, []
  end

  scope "/api/swagger" do
    pipe_through :api
    get "/", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  scope "/api", CryptoStreamWeb do
    pipe_through :api

    post "/register", AuthController, :register
    post "/login", AuthController, :login

    get "/prices", MarketController, :get_prices
    get "/historical/:coin_id", MarketController, :get_historical_prices
  end

  scope "/api", CryptoStreamWeb do
    pipe_through [:api, :auth]

    post "/trading/buy", TradingController, :buy
    get "/trading/transactions", TradingController, :list_transactions
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:crypto_stream, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: CryptoStreamWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
