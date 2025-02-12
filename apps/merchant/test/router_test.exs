defmodule Merchant.RouterTest do
  use ExUnit.Case

  setup_all do
    current = Application.get_env(:merchant, :routing_table)
    computer_name = System.get_env("COMPUTER_NAME", "PC-Cazu")

    Application.put_env(:merchant, :routing_table, [
      {?a..?m, :"foo@#{computer_name}"},
      {?n..?z, :"bar@#{computer_name}"}
    ])

    on_exit(fn -> Application.put_env(:merchant, :routing_table, current) end)
  end

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
