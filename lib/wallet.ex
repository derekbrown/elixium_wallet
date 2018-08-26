defmodule Wallet do
  alias Elixium.Transaction
  alias Elixium.Utilities
  alias Elixium.Store.Utxo
  alias Elixium.KeyPair

  def new_transaction(address, amount, desired_fee)  do
    inputs = find_suitable_inputs(amount + desired_fee)
    designations = [%{amount: amount, addr: address}]

    designations = if Transaction.sum_inputs(inputs) > amount + desired_fee do
      # Since a UTXO is fully used up when we put it in a new transaction, we must create a new output
      # that credits us with the change
      [%{amount: Transaction.sum_inputs(inputs) - (amount + desired_fee), addr: "MY OWN ADDR"} | designations]
    else
      designations
    end

    tx =
      %Transaction{
        designations: designations,
        inputs: inputs,
        timestamp: DateTime.utc_now |> DateTime.to_string
      }

    # The transaction ID is just the merkle root of all the inputs, concatenated with the timestamp
    id =
      Transaction.calculate_hash(tx) <> tx.timestamp
      |> Utilities.sha_base16()

    tx = %{tx | id: id}
    Map.merge(tx, Transaction.calculate_outputs(tx))
  end

  @doc """
    Return all UTXOs that are owned by the given public key
  """
  @spec find_pubkey_utxos(String.t) :: list
  def find_pubkey_utxos(public_key) do
    Utxo.find_by_address(public_key)
  end

  def find_wallet_utxos do
    case File.ls(".keys") do
      {:ok, keyfiles} ->
        Enum.flat_map(keyfiles, fn file ->
          {pub, priv} = KeyPair.get_from_file(".keys/#{file}")

          pub
          |> Base.encode16()
          |> find_pubkey_utxos()
          |> Enum.map( &(Map.merge(&1, %{signature: KeyPair.sign(priv, &1.txoid) |> Base.encode16})) )
        end)
      {:error, :enoent} -> IO.puts "No keypair file found"
    end
  end

  @doc """
    Take all the inputs that we have the necessary credentials to utilize, and then return
    the most possible utxos whos amounts add up to the amount passed in
  """
  @spec find_suitable_inputs(number) :: list
  def find_suitable_inputs(amount) do
    find_wallet_utxos()
    |> Enum.sort(&(&1.amount < &2.amount))
    |> take_necessary_utxos(amount)
  end

  defp take_necessary_utxos(utxos, amount), do: take_necessary_utxos(utxos, [], amount)
  defp take_necessary_utxos(_utxos, chosen, amount) when amount <= 0, do: chosen
  defp take_necessary_utxos(utxos, chosen, amount) do
    [utxo | remaining] = utxos

    take_necessary_utxos(remaining, [utxo | chosen], amount - utxo.amount)
  end

end
