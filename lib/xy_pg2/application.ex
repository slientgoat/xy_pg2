defmodule XyPg2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec

  def start(_type, _args) do
    # List all child processes to be supervised
    server_name =
      Application.get_env(:xy_pg2, :server_name) ||
        raise "config :xy_pg2, server_name:  is nil in repository configuration"

    master_node =
      Application.get_env(:xy_pg2, :master_node) ||
        raise "config :xy_pg2, master_node:  is nil in repository configuration,or remove {:xy_pg2,xxx.xy_pg2.git} from mix.exs when the current node is't master node"

    children = [
      # Starts a worker by calling: XyPg2.Worker.start_link(arg)
      {XyPg2.Worker, [server_name: server_name, master_node: master_node]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: XyPg2.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
