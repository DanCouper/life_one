defmodule Cell.Supervisor do
  use Supervisor

  @moduledoc """
  Manages all dynamically added cell processes
  """

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Init does not actually spin up the child processes: instead
  it delegates to the `children` function. Instead of immediately
  creating, want to describe the type of processes that will be
  supervised in future:
  """
  def init([]) do
    children = [
      worker(Cell.Worker, [])
    ]

    supervise(children, strategy: :simple_one_for_one, restart: :transient)
  end

  @doc """
  Returns all living cell processes currently being supervised. Needed to
  allow `Universe` to tick each cell.
  """
  def children do
    Cell.Supervisor
    |> Supervisor.which_children
    |> Enum.map(fn {_,pid,_,_} -> pid end)
  end
end
