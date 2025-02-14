defmodule Merchant.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` request to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    first = :binary.first(bucket)

    entry = Enum.find(table(), fn {enum, _node} -> first in enum end) || no_entry_error(bucket)

    if elem(entry, 1) == node() do
      apply(mod, fun, args)
    else
      {Merchant.RouterTasks, elem(entry, 1)}
      |> Task.Supervisor.async(Merchant.Router, :route, [bucket, mod, fun, args])
      |> Task.await()
    end
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect(bucket)} in table #{inspect(table())}"
  end

  @doc """
  Returns the routing table.
  """
  def table do
    Application.fetch_env!(:merchant, :routing_table)
  end
end
