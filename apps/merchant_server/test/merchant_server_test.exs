defmodule MerchantServerTest do
  use ExUnit.Case
  @moduletag :capture_log

  setup do
    Application.stop(:merchant)
    :ok = Application.start(:merchant)
  end

  setup do
    opts = [:binary, packet: :line, active: false]
    {:ok, socket} = :gen_tcp.connect(~c"localhost", 4040, opts)
    %{socket: socket}
  end

  test "server interaction", %{socket: socket} do
    assert send_and_recv(socket, "UNKNOWN shopping\r\n") == "UNKNOWN COMMAND\r\n"

    assert send_and_recv(socket, "GET shopping elixir\r\n") == "NOT FOUND\r\n"

    assert send_and_recv(socket, "CREATE shopping\r\n") == "OK\r\n"

    assert send_and_recv(socket, "PUT shopping elixir 4\r\n") == "OK\r\n"

    assert send_and_recv(socket, "GET shopping elixir\r\n") == "4\r\n"
    assert send_and_recv(socket, "") == "OK\r\n"

    assert send_and_recv(socket, "DELETE shopping elixir\r\n") == "OK\r\n"

    assert send_and_recv(socket, "GET shopping elixir\r\n") == "NOT FOUND\r\n"
  end

  defp send_and_recv(socket, command) do
    :ok = :gen_tcp.send(socket, command)
    {:ok, data} = :gen_tcp.recv(socket, 0, 1000)
    data
  end
end
