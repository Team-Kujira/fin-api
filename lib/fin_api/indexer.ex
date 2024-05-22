defmodule FinApi.Indexer do
  alias FinApi.Trades
  alias Phoenix.PubSub
  use GenServer
  require Logger

  @impl true
  def init(opts) do
    PubSub.subscribe(FinApi.PubSub, "tendermint/event/Tx")

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
    trades = Enum.flat_map(events, &scan_event/1)

    for {trade, idx} <- Enum.with_index(trades) do
      trade
      |> Map.merge(%{
        height: height,
        tx_idx: index,
        idx: idx,
        txhash: txhash,
        protocol: "fin",
        timestamp: DateTime.now!("Etc/UTC")
      })
      |> Trades.insert_trade()
    end

    {:noreply, state}
  end

  defp scan_event(%{attributes: attributes}) do
    scan_attributes(attributes)
  end

  defp scan_attributes(attributes, collection \\ [])

  defp scan_attributes(
         [
           %{key: "market", value: market},
           %{key: "base_amount", value: base_amount},
           %{key: "quote_amount", value: quote_amount},
           %{key: "type", value: type} | rest
         ],
         collection
       ) do
    base_amount = String.to_integer(base_amount)
    quote_amount = String.to_integer(quote_amount)

    order = %{
      contract: market,
      base_amount: base_amount,
      quote_amount: quote_amount,
      price: Decimal.from_float(quote_amount / base_amount),
      type: type
    }

    scan_attributes(rest, [order | collection])
  end

  defp scan_attributes([_ | rest], collection), do: scan_attributes(rest, collection)
  defp scan_attributes([], collection), do: collection
end
