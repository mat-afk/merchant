defmodule MerchantTest do
  use ExUnit.Case
  doctest Merchant

  test "greets the world" do
    assert Merchant.hello() == :world
  end

  test "worlds the greet" do
    assert Merchant.world() == :hello
  end
end
