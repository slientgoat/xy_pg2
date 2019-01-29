defmodule XyPg2.Worker do
  @moduledoc false

  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:server_name], name: opts[:server_name])
  end

  def init(server_name) do
    pg2_group = pg2_namespace(server_name)
    :ok = :pg2.create(pg2_group)
    :ok = :pg2.join(pg2_group, self())
    state = %{node_name: node(), server_name: server_name}
    {:ok, state}
  end

  def apply_in_master(master_node, server_name, module, fun, args) when is_atom(master_node) do
    cond do
      master_node == node() ->
        apply_in_local(module, fun, args)

      true ->
        apply_forward_to_local({server_name, master_node}, module, fun, args)
    end
  end

  def apply_in_members(server_name, module, fun, args) do
    server_name
    |> get_members()
    |> do_apply(module, fun, args)
  end

  defp do_apply({:error, {:no_such_group, _}}, _module, _fun, _args) do
    {:error, :no_such_group}
  end

  defp do_apply(pids, module, fun, args) when is_list(pids) do
    Enum.each(
      pids,
      fn
        pid when is_pid(pid) and node(pid) == node() ->
          apply_in_local(module, fun, args)

        pid_or_tuple ->
          apply_forward_to_local(pid_or_tuple, module, fun, args)
      end
    )

    :ok
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
  end

  def handle_cast(_msg, state) do
    {:noreply, state}
  end

  def handle_info({:forward_to_local, module, fun, args}, state) do
    apply_in_local(module, fun, args)
    {:noreply, state}
  end

  defp get_members(server_name) do
    :pg2.get_members(pg2_namespace(server_name))
  end

  defp pg2_namespace(server_name), do: {:xy_phx, server_name}

  defp apply_in_local(module, fun, args) do
    Logger.info("XyPg2 apply in local:  apply(#{module},:#{fun},#{inspect(args, pretty: true)})")
    apply(module, fun, args)
  end

  defp apply_forward_to_local(pid_or_tuple, module, fun, args) do
    Logger.info(
      "XyPg2 forward to local:  apply(#{module},:#{fun},#{inspect(args, pretty: true)})"
    )

    send(pid_or_tuple, {:forward_to_local, module, fun, args})
  end
end
