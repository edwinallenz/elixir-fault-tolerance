defmodule FaultTolerance.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      FaultTolerance.Receiver
    ]

    Supervisor.init(children, strategy: :one_for_all)

  end
end
