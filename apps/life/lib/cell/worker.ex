defmodule Cell.Worker do
  use GenServer

  @moduledoc """
  The universe defers most of the work to individual
  cells: this contains most of the computation.
  """

  @offsets [
    {-1, -1}, { 0, -1}, { 1, -1},
    {-1,  0},           { 1,  0},
    {-1,  1}, { 0,  1}, { 1,  1}
  ]

  def start_link(position) do
    GenServer.start_link(__MODULE__, position, name: {
      :via, Registry, {Cell.Registry, position}
    })
  end

  @doc """
  Removes the given cell process from the `Cell.Supervisor` tree.
  """
  def reap(process) do
    Supervisor.terminate_child(Cell.Supervisor, process)
  end

  @doc """
  `sow` creates a new process under the `Cell.Supervisor` tree, with
  `position` as the initial state.
  """
  def sow(position) do
    Supervisor.start_child(Cell.Supervisor, [position])
  end

  @doc """
  During each `tick`, a cell needs to generate a list of
  cells to reap (either an empty list, or one containing
  itself), and a list of cells to sow.
  """
  def tick(process) do
    GenServer.call(process, {:tick})
  end

  def count_neighbours(process) do
    GenServer.call(process, {:count_neighbours})
  end

  @doc """
  `lookup` gets called on each position, and translates
  the cell position into a PID for that cell's active process.

  `Registry.lookup` returns a list of `{pid,value}` tuples
  (or an empty list). As we only want the `pid`, that gets pulled out.

  We can the use `Process.alive?` to filter. This is important:
  after using `Supervisor.terminate_child` to reap, the cell's process
  will be removed from the `Cell.Supervisor`, but the process may not
  be fully removed from the `Cell.Registry`, leaving "ghost cells" that
  can cause frustrating, subtle bugs.

  Filtering using `Process.alive?` prevents this; these ghost cells
  will never interact with the live cells.
  """
  def lookup(position) do
    Cell.Registry
    |> Registry.lookup(position)
    |> Enum.map(fn
      {pid, _valid} -> pid
      nil -> nil
    end)
    |> Enum.filter(&Process.alive?/1)
    |> List.first
  end

  ###

  @doc """
  `to_reap` checks the living neighbours around the cell.
  If there are two or three, the cell lives on. Otherwise
  it dies from loneliness.

  `to_sow` looks for any dead (unoccupies) neighbours, and
  filtering those that do not have enough living neighbours
  to be born into the the next generation.

  Once these are calculated, the reply can be sent back to
  the `Universe`, with `position` as the current state.
  """
  def handle_call({:tick}, _from, position) do
    to_reap = position
      |> do_count_neighbours
      |> case do
        2 -> []
        3 -> []
        _ -> [self()]
      end

    to_sow = position
      |> neighbouring_positions
      |> keep_dead
      |> keep_valid

    {:reply, {to_reap, to_sow}, position}
  end

  def handle_call({:count_neighbours}, _from, position) do
    {:reply, do_count_neighbours(position), position}
  end

  ###

  # Finds all eight neighbouring positions,
  # filters out dead neighbours, then returns the
  # number [length] of the resulting list of living
  # neighbours.
  defp do_count_neighbours(position) do
    position
    |> neighbouring_positions
    |> keep_live
    |> length
  end

  defp neighbouring_positions({x,y}) do
    Enum.map(@offsets, fn {dx, dy} -> {x + dx, y + dy} end)
  end

  # Paired functions to decide whether cells are alive or dead
  # by calling `lookup` to check the registry.
  defp keep_live(positions), do: Enum.filter(positions, &(lookup(&1) != nil))
  defp keep_dead(positions), do: Enum.filter(positions, &(lookup(&1) == nil))

  # Goes through the provided list of unoccupied positions,
  # filtering out those without 3 neighbours. This means dead
  # cells with exactly three neighbours (one of whom is the
  # current cell) will be born into the next generation.
  defp keep_valid(positions), do: Enum.filter(positions, &(do_count_neighbours(&1) == 3))
end
