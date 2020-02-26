defmodule FaultToleranceTest do
  use ExUnit.Case
  doctest FaultTolerance

  test "greets the world" do
    assert FaultTolerance.hello() == :world
  end
end
