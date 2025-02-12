defmodule MerchantServer.Command do
  @doc ~S"""
  Parses the given `line` into a command

  ## Examples

      iex> MerchantServer.Command.parse("CREATE shopping\r\n")
      {:ok, {:create, "shopping"}}

      iex> MerchantServer.Command.parse("CREATE shopping   \r\n")
      {:ok, {:create, "shopping"}}

      iex> MerchantServer.Command.parse("PUT shopping elixir 1\r\n")
      {:ok, {:put, "shopping", "elixir", "1"}}

      iex> MerchantServer.Command.parse("GET shopping elixir\r\n")
      {:ok, {:get, "shopping", "elixir"}}

      iex> MerchantServer.Command.parse("DELETE shopping elixir\r\n")
      {:ok, {:delete, "shopping", "elixir"}}

  Unknown commands or commands with the wrong number of
  arguments return an error:

      iex> MerchantServer.Command.parse("UNKNOWN shopping elixir\r\n")
      {:error, :unknown_command}

      iex> MerchantServer.Command.parse("GET shopping\r\n")
      {:error, :unknown_command}

  """
  def parse(line) do
    case String.split(line) do
      ["CREATE", bucket] -> {:ok, {:create, bucket}}
      ["PUT", bucket, key, value] -> {:ok, {:put, bucket, key, value}}
      ["GET", bucket, key] -> {:ok, {:get, bucket, key}}
      ["DELETE", bucket, key] -> {:ok, {:delete, bucket, key}}
      _ -> {:error, :unknown_command}
    end
  end

  @doc """
  Runs the given `command`.
  """
  def run(command)

  def run({:create, bucket}) do
    case Merchant.Router.route(bucket, Merchant.Registry, :create, [Merchant.Registry, bucket]) do
      pid when is_pid(pid) -> {:ok, "OK\r\n"}
      _ -> {:error, "FAILED TO CREATE BUCKET\r\n"}
    end
  end

  def run({:put, bucket, key, value}) do
    lookup(bucket, fn pid -> Merchant.Bucket.put(pid, key, value) end)
    {:ok, "OK\r\n"}
  end

  def run({:get, bucket, key}) do
    lookup(bucket, fn pid ->
      case Merchant.Bucket.get(pid, key) do
        nil -> {:error, :not_found}
        value -> {:ok, "#{value}\r\nOK\r\n"}
      end
    end)
  end

  def run({:delete, bucket, key}) do
    lookup(bucket, fn pid -> Merchant.Bucket.delete(pid, key) end)
    {:ok, "OK\r\n"}
  end

  defp lookup(bucket, callback) do
    case Merchant.Router.route(bucket, Merchant.Registry, :lookup, [Merchant.Registry, bucket]) do
      {:ok, pid} -> callback.(pid)
      :error -> {:error, :not_found}
    end
  end
end
