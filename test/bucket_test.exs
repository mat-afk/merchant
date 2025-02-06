defmodule Merchant.BucketTest do
  use ExUnit.Case, async: true

  setup do
    bucket = start_supervised!(Merchant.Bucket)
    %{bucket: bucket}
  end

  test "store values by key", %{bucket: bucket} do
    assert Merchant.Bucket.get(bucket, "elixir") == nil

    Merchant.Bucket.put(bucket, "elixir", 1)
    assert Merchant.Bucket.get(bucket, "elixir") == 1
  end

  test "delete keys from the bucket", %{bucket: bucket} do
    Merchant.Bucket.put(bucket, "elixir", 1)
    assert Merchant.Bucket.delete(bucket, "elixir") == 1

    assert Merchant.Bucket.delete(bucket, "elixir") == nil
  end

  test "buckets are temporary workers" do
    assert Supervisor.child_spec(Merchant.Bucket, []).restart == :temporary
  end
end
