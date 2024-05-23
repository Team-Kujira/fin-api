defmodule FinApi.Indexer do
  alias FinApi.Trades
  alias Phoenix.PubSub
  use GenServer
  require Logger

  @impl true
  def init(opts) do
    PubSub.subscribe(FinApi.PubSub, "tendermint/event/Tx")
    PubSub.subscribe(FinApi.PubSub, "tendermint/event/NewBlockHeader")

    {:ok, opts}
  end

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  @impl true

  def handle_info(
        %{TxResult: %{height: height, result: %{events: events}, tx: tx} = res},
        state
      ) do
    txhash = tx |> Base.decode64!() |> Kujira.tx_hash()
    index = Map.get(res, :index, 0)
    Trades.Indexer.scan_events(height, index, txhash, events)
    {:noreply, state}
  end

  def handle_info(
        %{
          header: %{height: height, last_block_id: %{hash: hash}},
          result_end_block: %{events: events}
        },
        state
      ) do
    # Assign max number as this is end block
    index = 2_147_483_647
    Trades.Indexer.scan_events(height, index, hash, events)

    {:noreply, state}
  end
end
