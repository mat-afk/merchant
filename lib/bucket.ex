defmodule Merchant.Bucket do
  use Agent

  @doc """
  Starts a new bucket
  """
  def start_link(_options) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Gets a value from the bucket by key
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Puts a value for the given key in the bucket
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Deletes a given `key` from the bucket

  Returns the current value associated with the the key
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
