defmodule Interface.LifeChannel do
  use Phoenix.Channel

  @doc """
  Firstly, 'restarts' the simulation by killing all
  living cells. Then spawn cells in start positions.
  Finally, return the list of positions of living cells.
  """
  def join("life", _, socket) do
    Enum.map(Cell.Supervisor.children, &Cell.Worker.reap/1)
    Enum.map(Patterns.diehard(20,20), &Cell.Worker.sow/1)
    {:ok, %{positions: Cell.Supervisor.positions}, socket}
  end

  @doc """
  Firstly, ticks the universe to update our little guys.
  Then broadcast the positions of all the cells.
  Then return with no reply.
  """
  def handle_in("tick", _, socket) do
    Universe.Worker.tick

    broadcast!(socket, "tick", %{postions: Cell.Supervisor.positions})

    {:noreply, socket}
  end

end
