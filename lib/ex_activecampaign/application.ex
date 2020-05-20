defmodule ExActivecampaign.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    children =
      case args do
        [env: :prod] ->
          []

        [env: :test] ->
          [
            {
              Plug.Cowboy,
              scheme: :http, plug: ExActivecampaign.MockServer, options: [port: 8081]
            }
          ]

        [env: :dev] ->
          []

        [_] ->
          []
      end

    opts = [strategy: :one_for_one, name: ExActivecampaign.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
