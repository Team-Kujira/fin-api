defmodule FinApiWeb.TradesController do
  alias FinApi.Trades
  use FinApiWeb, :controller

  def index(conn, %{"pair" => contract} = params) do
    with {limit, ""} <- params |> Map.get("limit", "100") |> Integer.parse() do
      limit = min(limit, 100)
      trades = Trades.list_trades(contract, limit)
      json(conn, %{trades: trades})
    end
  end

  def index(conn, params) do
    with {limit, ""} <- params |> Map.get("limit", "100") |> Integer.parse() do
      limit = min(limit, 100)
      trades = Trades.all_trades(limit)
      json(conn, %{trades: trades})
    end
  end
end
