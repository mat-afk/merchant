defmodule Merchant.Supervisor do
  use Supervisor

  def start_link(options) do
    Supervisor.start_link(__MODULE__, :ok, options)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: Merchant.BucketSupervisor, strategy: :one_for_one},
      {Merchant.Registry, name: Merchant.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
