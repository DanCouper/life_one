defmodule Universe.Supervisor do
  use Supervisor

  @moduledoc """
  The top level supervisor. Creates a single Universe.Worker,
  whose job it is is to tick the existing cells, one
  Cell.Supervisor who supervises the individual cells as
  they are dynamically created and destroyed, and Cell.Registry,
  which is an instance of the Elixir Registry.
  """
  def start(_type, _args) do
    start_link()
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      worker(Universe.Worker, []),
      supervisor(Cell.Supervisor, []),
      supervisor(Registry, [:unique, Cell.Registry])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
