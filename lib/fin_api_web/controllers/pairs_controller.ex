defmodule FinApiWeb.PairsController do
  alias FinApi.TradingView
  alias FinApi.Candles
  alias FinApi.Trades
  use FinApiWeb, :controller
  @earliest NaiveDateTime.from_iso8601!("2022-06-01T00:00:00Z")

  def show(
        conn,
        %{
          "id" => contract,
          "candles" => %{
            "from" => from,
            "to" => to,
            "precision" => precision
          }
        } = params
      ) do
    with {:ok, pair} <- Kujira.Fin.get_pair(FinApi.Node.channel(), contract),
         {:ok, pair} <- Kujira.Fin.load_pair(FinApi.Node.channel(), pair),
         {:ok, from} <- NaiveDateTime.from_iso8601(from),
         {:ok, to} <- NaiveDateTime.from_iso8601(to),
         {limit, ""} <-
           params |> Map.get("trades", %{}) |> Map.get("limit", "100") |> Integer.parse() do
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

      trades = Trades.all_trades(min(limit, 100))

      candles =
        Candles.list_candles(
          contract,
          TradingView.truncate(from, precision),
          TradingView.truncate(to, precision),
          precision
        )

      json(conn, %{pair: pair, candles: candles, trades: trades})
    end
  end
end
