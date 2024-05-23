defmodule FinApiWeb.PairsController do
  alias Kujira.Fin
  alias FinApi.Summaries
  alias FinApi.Trades
  use FinApiWeb, :controller

  def index(conn, %{"address" => address}) do
    summaries = Summaries.list_summaries()

    with {:ok, pairs} <- Fin.list_pairs(FinApi.Node.channel()),
         {:ok, pairs} <- pairs |> merge_summaries(summaries) |> load_orders(address) do
      json(conn, %{pairs: pairs})
    end
  end

  def index(conn, _) do
    summaries = Summaries.list_summaries()

    with {:ok, pairs} <- Fin.list_pairs(FinApi.Node.channel()) do
      json(conn, merge_summaries(pairs, summaries))
    end
  end

  def show(conn, %{"id" => contract, "address" => address} = params) do
    summaries = Summaries.list_summaries()

    with {:ok, data} <- load_pair(contract, params, summaries),
         {:ok, orders} <-
           Fin.list_orders(FinApi.Node.channel(), data.pair, address) do
      json(conn, Map.put(data, :orders, orders))
    end
  end

  def show(conn, %{"id" => contract} = params) do
    summaries = Summaries.list_summaries()

    with {:ok, data} <- load_pair(contract, params, summaries) do
      json(conn, Map.put(data, :orders, []))
    end
  end

  defp load_pair(address, params, summaries) do
    with {:ok, pair} <- Fin.get_pair(FinApi.Node.channel(), address),
         {:ok, pair} <- Fin.load_pair(FinApi.Node.channel(), pair),
         {limit, ""} <-
           params |> Map.get("trades", %{}) |> Map.get("limit", "100") |> Integer.parse() do
      trades = Trades.all_trades(min(limit, 100))

      {:ok, %{pair: pair, trades: trades, summary: Map.get(summaries, pair.address)}}
    end
  end

  defp load_orders(pairs, address) do
    Task.async_stream(pairs, fn pair ->
      case Fin.list_orders(FinApi.Node.channel(), pair.pair, address) do
        {:ok, orders} ->
          Map.put(pair, :orders, orders)

        _ ->
          Map.put(pair, :orders, [])
      end
    end)
    |> Enum.reduce({:ok, []}, fn
      {:ok, x}, {:ok, agg} -> {:ok, [x | agg]}
      _, {:error, err} -> {:error, err}
      err, _ -> err
    end)
  end

  defp merge_summaries(pairs, summaries) do
    Enum.map(pairs, &%{pair: &1, summary: Map.get(summaries, &1.address)})
  end
end
