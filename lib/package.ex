defmodule FaultTolerance.Package do
  defstruct [:id, :contents]

  alias FaultTolerance.Package

  def new(contents) do
    %Package{
      id: generate_id(),
      contents: contents,
    }
  end

  def random do
    ["leo", "duis", "ut", "diam", "quam", "nulla", "porttitor", "massa", "id", "neque", "aliquam", "vestibulum", "morbi", "blandit", "cursus", "risus", "ultrices", "tempus"]
    |> Enum.map(&(String.capitalize(&1)))
    |> Enum.random
    |> new
  end

  def random_batch(n), do: Stream.repeatedly(&Package.random/0) |> Enum.take(n)

  defp generate_id do
    :crypto.strong_rand_bytes(10)
    |> Base.url_encode64
    |> binary_part(0,10)
    |> String.upcase
    |> String.replace(~r/[-_]/, "X")
  end
end
