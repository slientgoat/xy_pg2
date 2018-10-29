# XyPg2

**do apply(module,fun,args) on nodes of cluster**

## Installation
## Becareful: Only the current node you desired that must be the master node



If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `xy_pg2` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:xy_pg2, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/xy_pg2](https://hexdocs.pm/xy_pg2).

## TO USE

add it in yourappdir/configs/config.exs

```elixir
config :xy_pg2, server_name: XyPg2,master_node: node()
```