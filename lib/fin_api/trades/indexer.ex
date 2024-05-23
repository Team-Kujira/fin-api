defmodule FinApi.Trades.Indexer do
  alias FinApi.Trades

  def scan_events(height, tx_idx, txhash, events) do
    trades = Enum.flat_map(events, &scan_event/1)

    for {trade, idx} <- Enum.with_index(trades) do
      trade
      |> Map.merge(%{
        height: height,
        tx_idx: tx_idx,
        idx: idx,
        txhash: txhash,
        protocol: "fin",
        timestamp: DateTime.now!("Etc/UTC")
      })
      |> Trades.insert_trade()
    end
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
    scan_attributes(
      rest,
      insert_trade(collection, market, base_amount, quote_amount, type)
    )
  end

  defp scan_attributes(
         [
           %{key: "base_amount", value: base_amount},
           %{key: "market", value: market},
           %{key: "quote_amount", value: quote_amount},
           %{key: "type", value: type} | rest
         ],
         collection
       ) do
    scan_attributes(
      rest,
      insert_trade(collection, market, base_amount, quote_amount, type)
    )
  end

  defp scan_attributes([_ | rest], collection), do: scan_attributes(rest, collection)
  defp scan_attributes([], collection), do: collection

  defp insert_trade(collection, _market, base_amount, quote_amount, _type)
       when base_amount == "0" or quote_amount == "0",
       do: collection

  defp insert_trade(collection, market, base_amount, quote_amount, type) do
    base_amount = String.to_integer(base_amount)
    quote_amount = String.to_integer(quote_amount)

    order = %{
      contract: market,
      base_amount: base_amount,
      quote_amount: quote_amount,
      price: Decimal.from_float(quote_amount / base_amount),
      type: type
    }

    [order | collection]
  end
end
