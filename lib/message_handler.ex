defmodule MessageHandler do
  use GenServer
  alias Elixium.P2P.Peer

  def start_link do
    GenServer.start_link(__MODULE__, self())
  end

  def init(parent_pid) do
    p2p_supervisor = Peer.initialize

    {:ok, {p2p_supervisor}}
  end

  def handle_info(msg, {p2p_supervisor}) do
    IO.puts("received something")
  end

end
