defmodule Merchant.Registry do
  use GenServer

  @doc """
  Starts the registry with the given options.

  `:name` is always required.
  """
  def start_link(options) do
    server = Keyword.fetch!(options, :name)
    GenServer.start_link(__MODULE__, server, options)
  end

  @doc """
  Looks up the bucket pid for the `name` stored in the `server`

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise
  """
  def lookup(server, name) do
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in the server
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  @impl true
  def init(table) do
    names = :ets.new(table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:create, name}, _from, {names, refs}) do
    case lookup(names, name) do
      {:ok, bucket} ->
        {:reply, bucket, {names, refs}}

      :error ->
        {:ok, bucket} = DynamicSupervisor.start_child(Merchant.BucketSupervisor, Merchant.Bucket)
        ref = Process.monitor(bucket)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, bucket})
        {:reply, bucket, {names, refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end

  @impl true
  def handle_info(message, state) do
    require Logger
    Logger.debug("Unexpected message in #{__MODULE__}: #{inspect(message)}")
    {:noreply, state}
  end
end
