import Config

config :merchant, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  computer_name = System.get_env("COMPUTER_NAME", "PC-Cazu")

  config :merchant, :routing_table, [
    {?a..?m, :"foo@#{computer_name}"},
    {?n..?z, :"bar@#{computer_name}"}
  ]
end
