defmodule Merchant.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = Merchant.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "store values by key", %{bucket: bucket} do
    assert Merchant.Bucket.get(bucket, "elixir") == nil

    Merchant.Bucket.put(bucket, "elixir", 1)
    assert Merchant.Bucket.get(bucket, "elixir") == 1
  end
end
