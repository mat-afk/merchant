defmodule Merchant.BucketTest do
  use ExUnit.Case, async: true

  test "store values by key" do
    {:ok, bucket} = Merchant.Bucket.start_link([])
    assert Merchant.Bucket.get(bucket, "elixir") == nil

    Merchant.Bucket.put(bucket, "elixir", 1)
    assert Merchant.Bucket.get(bucket, "elixir") == 1
  end
end
