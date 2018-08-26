defmodule ActionHandler do
  alias Elixium.KeyPair

  def initialize do
    {:ok, message_handler} = MessageHandler.start_link()

    main(message_handler)
  end

  def main(message_handler) do
    "What do you want to do? > "
    |> IO.gets()
    |> String.trim("\n")
    |> handle_action(message_handler)

    main(message_handler)
  end

  defp handle_action("transaction", message_handler) do
    Wallet.new_transaction("someone", 10, 1)
  end

  defp handle_action("new keypair", _) do
    {pub, priv} = KeyPair.create_keypair()

    IO.puts "Created keypair. Public key is #{Base.encode64(pub)}"
  end

  defp handle_action(_, _), do:   IO.puts "I don't know how to help with that."

end
