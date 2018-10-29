defmodule XyPg2 do
  @moduledoc """
  Documentation for XyPg2.
  """
  alias XyPg2.Worker
  defmacro __using__(opts) do

    quote do
      @server_name unquote(opts)[:server_name]
      @master_node Application.get_env(:xy_pg2, :master_node)
      def apply_in_members(presence_name, f, a) do
        Worker.apply_in_members(@server_name, presence_name, f, a)
      end

      def apply_in_master(presence_name, f, a) do
        Worker.apply_in_master(@master_node, @server_name, presence_name, f, a)
      end


    end
  end
end
