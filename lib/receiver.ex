defmodule FaultTolerance.Receiver do
  use GenServer

  alias FaultTolerance.Receiver

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_) do
    state = %{
      assignments: [],
    }

    {:ok, state}
  end

  def recieve_packages(packages) do
    GenServer.cast(__MODULE__, {:recieve_packages, packages})
  end

  def recieve_and_chunck(packages, count) do
    packages
    |> Enum.chunk_every(count)
    |> Enum.each(&(recieve_packages(&1)))
  end

  def handle_info({:package_delivered, package}, state) do
    IO.puts "Package #{inspect package} was delivered."
    delivered_package = state.assignments |> Enum.filter(fn({assigned_package, pid}) ->
      assigned_package == package
    end
    ) |> List.first
    new_assigments = List.delete(state.assignments, delivered_package)
    state =  %{state | assignments: new_assigments}
    {:noreply, state}
  end

  def handle_cast({:recieve_packages, packages}, state) do
    IO.puts "Received #{Enum.count(packages)} packages"
    {:ok, deliverator} = FaultTolerance.Delivery.start
    Process.monitor(deliverator)
    new_state = assign_packages(state, deliverator, packages)
    FaultTolerance.Delivery.deliver_packages(deliverator, packages)
    {:noreply, new_state}
  end

  def handle_info({:DOWN, _ref, :process, deliverator, :normal}, state) do
    IO.puts("Finish...........")
    {:noreply, state}
  end

  def handle_info({:DOWN, _ref, :process, deliverator, reason}, state) do
    IO.puts "Delivarator #{inspect deliverator} is down....."
    failed_assignments = filter_by_deliverator(deliverator, state.assignments)
    failed_packages = Enum.map(failed_assignments, fn({package, _deliverator_pid}) -> package end)
    new_assignments = state.assignments -- failed_assignments
    state = %{state | assignments: new_assignments}
    recieve_packages(failed_packages)
    {:noreply, state}
  end

  defp assign_packages(state, deliverator_pid, packages) do
    IO.inspect state
    new_assignments = Enum.map(packages, &({&1, deliverator_pid}))
    assignments = new_assignments ++ state.assignments
    %{state | assignments: assignments}
  end

  defp filter_by_deliverator(deliverator, packages) do
    packages |> Enum.filter(fn({_package, pid}) ->
      pid == deliverator
    end)
  end
end
