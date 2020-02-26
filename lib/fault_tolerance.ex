defmodule FaultTolerance do
  use Application

  def start(_type, _args) do
    FaultTolerance.Supervisor.start_link()
  end
end
