defmodule FaultTolerance.Delivery do
  use GenServer

  def start do
    GenServer.start(__MODULE__,[])
  end

  def deliver_packages(pid, packages) do
    GenServer.cast(pid, {:deliver_packages, packages})
  end

  def handle_cast({:deliver_packages, packages}, state) do
    deliver(packages)
    {:noreply, state}
  end

  def deliver([]), do: Process.exit(self(), :normal)
  def deliver([package | remain_packages]) do
    IO.puts("Delivering package #{inspect package} from #{inspect self()}")
    make_delivery()
    send(Elixir.FaultTolerance.Receiver, {:package_delivered, package})
    deliver(remain_packages)
  end

  defp make_delivery do
    :timer.sleep :rand.uniform(1_000)
    crash()
  end

  defp crash do
    crash_factor = :rand.uniform(100)
    IO.puts("Crash factor #{crash_factor}")
    if crash_factor > 90, do: raise "I'm crashing unable to deliver"
  end
end
