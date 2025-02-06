defmodule Merchant do
  use Application

  @moduledoc """
  Documentation for `Merchant`.
  """

  def start(_type, _args) do
    Merchant.Supervisor.start_link(name: Merchant.Supervisor)
  end
end
