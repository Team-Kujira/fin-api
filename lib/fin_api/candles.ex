defmodule FinApi.Candles do
  alias FinApi.Trades
  alias FinApi.Repo
  alias FinApi.Trades.Trade
  alias FinApi.TradingView
  import Ecto.Query

  def list_candles(contract, from, to, precision) do
    Trade
    |> where([t], t.timestamp >= ^from and t.contract == ^contract)
    |> Trades.sort(:desc)
    |> subquery()
    |> TradingView.with_range(from, to, precision)
    |> join(:right, [t], b in "bins",
      on:
        t.timestamp >= b.min and
          t.timestamp < b.max and
          t.contract == ^contract
    )
    |> select([t, b], %{
      bin: b.min,
      timestamp: t.timestamp,
      trade_price: t.price,
      quote_amount: t.quote_amount,
      high: over(max(t.price), :bins),
      low: over(min(t.price), :bins),
      open: over(first_value(t.price), :bins),
      close: over(last_value(t.price), :bins),
      volume: over(sum(t.quote_amount), :bins),
      rank: over(rank(), :bins),
      row_number: over(row_number(), :bins)
    })
    |> windows([t, b],
      bins: [
        partition_by: b.min,
        order_by: t.timestamp,
        frame: fragment("RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING")
      ]
    )
    |> subquery()
    |> group_by([:bin, :open, :close, :high, :low, :volume])
    |> select([b], %{
      bin: b.bin,
      high: b.high,
      low: b.low,
      open: b.open,
      close: b.close,
      volume: coalesce(b.volume, 0)
    })
    |> order_by(asc: :bin)
    |> Repo.all()
    |> fill_blanks()
    |> Enum.reverse()
  end

  defp fill_blanks(agg \\ [], _rem)

  defp fill_blanks([prev | agg], [%{close: nil, high: nil, low: nil, open: nil} = el | rest]) do
    filled = %{el | close: prev.close, high: prev.close, low: prev.close, open: prev.close}
    fill_blanks([filled, prev | agg], rest)
  end

  defp fill_blanks(agg, [x | rest]), do: fill_blanks([x | agg], rest)
  defp fill_blanks(agg, []), do: agg
end
