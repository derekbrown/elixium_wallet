defmodule Mix.Tasks.Wallet do
  use Mix.Task

  def run(_) do
    ActionHandler.initialize()
  end
end
