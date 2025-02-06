defmodule Merchant.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(Merchant.Registry)
    %{registry: registry}
  end

  test "spawns a named bucket", %{registry: registry} do
    assert Merchant.Registry.lookup(registry, "shopping") == :error

    Merchant.Registry.create(registry, "shopping")
    assert {:ok, bucket} = Merchant.Registry.lookup(registry, "shopping")

    Merchant.Bucket.put(bucket, "elixir", 1)
    assert Merchant.Bucket.get(bucket, "elixir") == 1
  end

  test "removes bucket on exit", %{registry: registry} do
    Merchant.Registry.create(registry, "shopping")
    {:ok, bucket} = Merchant.Registry.lookup(registry, "shopping")

    Agent.stop(bucket)
    assert Merchant.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Merchant.Registry.create(registry, "shopping")
    {:ok, bucket} = Merchant.Registry.lookup(registry, "shopping")

    Agent.stop(bucket, :shutdown)
    assert Merchant.Registry.lookup(registry, "shopping") == :error
  end
end
