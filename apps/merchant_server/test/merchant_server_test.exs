defmodule MerchantServerTest do
  use ExUnit.Case
  doctest MerchantServer

  test "greets the world" do
    assert MerchantServer.hello() == :world
  end
end
