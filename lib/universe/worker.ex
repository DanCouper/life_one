defmodule Universe.Worker do
	use GenServer

  @moduledoc """
  > Get all living cells. Asynchronously call tick on each one.
  > Wait for all of the ticks to finish. Kill, or reap, all cells
  > that will die from loneliness, and create, or sow, all of the
  > cells that will be born.
	"""

	def start_link do
		GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

	def tick do
    GenServer.call(__MODULE__, {:tick})
  end

	###

	@doc """
  The meat & potatoes.
  1. Calls the `Cell.Supervisor.children` function, which grabs the PIDs.
  2. Map over in parallel, running the `Cell.tick` on each process
  3. At this point, should have a list of cell coords to nuke, and a list
     of cell coords where new cells should be birthed. Reduce to a tuple
     of two flat lists for simplicity.
  4. Then iterate over both of those lists, firing the `Cell.reap` and
     `Cell.sow` functions respectively.
  """
	def handle_call({:tick}, _from, []) do
		Cell.Supervisor.children()
		|> Enum.map(&(Task.async(fn -> Cell.Worker.tick(&1) end)))
		|> Enum.map(&Task.await/1)
    |> Enum.reduce({[],[]}, &accumulate_ticks/2)
    |> reap_and_sow()
		{:reply, :ok, []}
	end

  defp accumulate_ticks({reap, sow}, {acc_reap, acc_sow}) do
    {acc_reap ++ reap, acc_sow ++ sow}
  end

  defp reap_and_sow({to_reap, to_sow}) do
		# FIXME these two calls to map are throwaway: reap and
    # sow are killing/creating processes as side effects.
    # Should really be each, but test first.
    Enum.map(to_reap, &Cell.Worker.reap/1)
    Enum.map(to_sow,  &Cell.Worker.sow/1)
  end
end
