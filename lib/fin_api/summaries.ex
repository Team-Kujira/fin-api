defmodule FinApi.Summaries do
  alias FinApi.Repo
  alias FinApi.Trades.Trade
  import Ecto.Query

  def list_summaries(since \\ NaiveDateTime.add(NaiveDateTime.utc_now(), 24 * 60 * 60 * -1)) do
    Trade
    |> where([t], t.timestamp >= ^since)
    |> select([x], %{
      x
      | close:
          over(last_value(x.price),
            partition_by: x.contract,
            order_by: x.timestamp,
            frame: fragment("RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING")
          ),
        open:
          over(first_value(x.price),
            partition_by: x.contract,
            order_by: x.timestamp,
            frame: fragment("RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING")
          )
    })
    |> subquery()
    |> group_by(:contract)
    |> select([x], %{
      contract: x.contract,
      quote_total: sum(type(x.quote_amount, :decimal)),
      base_total: sum(type(x.base_amount, :decimal)),
      high: max(x.price),
      low: min(x.price),
      open: min(x.open),
      close: min(x.close)
    })
    |> Repo.all()
    |> Enum.reduce(%{}, &Map.put(&2, &1.contract, &1))
  end
end
