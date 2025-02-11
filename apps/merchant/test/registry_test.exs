defmodule Merchant.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    _ = start_supervised!({Merchant.Registry, name: context.test})
    %{registry: context.test}
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

    _ = Merchant.Registry.create(registry, "bogus")
    assert Merchant.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    Merchant.Registry.create(registry, "shopping")
    {:ok, bucket} = Merchant.Registry.lookup(registry, "shopping")

    Agent.stop(bucket, :shutdown)

    _ = Merchant.Registry.create(registry, "bogus")
    assert Merchant.Registry.lookup(registry, "shopping") == :error
  end
end
