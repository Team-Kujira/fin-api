defmodule FinApiWeb.PairsController do
  alias FinApi.Trades
  use FinApiWeb, :controller
  @earliest NaiveDateTime.from_iso8601!("2022-06-01T00:00:00Z")

  def show(conn, %{"id" => contract, "address" => address} = params) do
    with {:ok, data} <- load_pair(contract, params),
         {:ok, orders} <-
           Kujira.Fin.list_orders(FinApi.Node.channel(), data.pair, address) do
      json(conn, Map.put(data, :orders, orders))
    end
  end

  def show(conn, %{"id" => contract} = params) do
    with {:ok, data} <- load_pair(contract, params) do
      json(conn, Map.put(data, :orders, []))
    end
  end

  defp load_pair(address, params) do
    with {:ok, pair} <- Kujira.Fin.get_pair(FinApi.Node.channel(), address),
         {:ok, pair} <- Kujira.Fin.load_pair(FinApi.Node.channel(), pair),
         {limit, ""} <-
           params |> Map.get("trades", %{}) |> Map.get("limit", "100") |> Integer.parse() do
      trades = Trades.all_trades(min(limit, 100))

      {:ok, %{pair: pair, trades: trades}}
    end
  end
end
