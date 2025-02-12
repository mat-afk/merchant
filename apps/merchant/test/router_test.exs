defmodule Merchant.RouterTest do
  use ExUnit.Case, async: true

  @tag :distributed
  test "route requests across nodes" do
    computer_name = System.get_env("COMPUTER_NAME", "PC-Cazu")

    assert Merchant.Router.route("hello", Kernel, :node, []) == :"foo@#{computer_name}"
    assert Merchant.Router.route("world", Kernel, :node, []) == :"bar@#{computer_name}"
  end

  test "raises on unknown entries" do
    assert_raise RuntimeError, ~r/could not find entry/, fn ->
      Merchant.Router.route(<<0>>, Kernel, :node, [])
    end
  end
end
