defmodule CryptoStreamWeb.ApiSpec do
  alias OpenApiSpex.{Components, Info, OpenApi, Paths, Server}
  alias CryptoStreamWeb.{Endpoint, Router}
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
      paths: Paths.from_router(Router)
    }
    |> OpenApiSpex.resolve_schema_modules() # Discover request/response schemas from path specs
  end
end
