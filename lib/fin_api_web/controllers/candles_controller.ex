defmodule FinApiWeb.CandlesController do
  alias FinApi.TradingView
  alias FinApi.Candles
  use FinApiWeb, :controller
  @earliest NaiveDateTime.from_iso8601!("2022-06-01T00:00:00Z")

  def show(conn, %{
        "id" => contract,
        "from" => from,
        "to" => to,
        "precision" => precision
      }) do
    with {:ok, from} <- NaiveDateTime.from_iso8601(from),
         {:ok, to} <- NaiveDateTime.from_iso8601(to) do
      latest = NaiveDateTime.utc_now()

      from =
        case NaiveDateTime.compare(from, @earliest) do
          :lt -> @earliest
          _ -> from
        end

      to =
        case NaiveDateTime.compare(to, latest) do
          :gt -> latest
          _ -> to
        end

      candles =
        Candles.list_candles(
          contract,
          TradingView.truncate(from, precision),
          TradingView.truncate(to, precision),
          precision
        )

      json(conn, %{candles: candles})
    end
  end
end
