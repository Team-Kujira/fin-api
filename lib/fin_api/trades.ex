defmodule FinApi.Trades do
  @moduledoc """
  Individual trades executed on Kujira FIN
  """
  alias FinApi.Repo
  alias FinApi.Trades.Trade
  import Ecto.Query

  @spec list_trades(String.t(), :asc | :desc, non_neg_integer()) :: [Trade.t()]
  def list_trades(contract, sort \\ :desc, limit \\ 100) do
    Trade
    |> where(contract: ^contract)
    |> sort(sort)
    |> limit(^limit)
    |> Repo.all()
  end

  def insert_trade(params) do
    Trade.changeset(%Trade{}, params)
    |> Repo.insert()
  end

  defp sort(query, :asc) do
    order_by(query, [x], [
      {:asc, x.timestamp},
      {:desc, x.id}
    ])
  end

  defp sort(query, :desc) do
    order_by(query, [x], [
      {:desc, x.timestamp},
      {:asc, x.id}
    ])
  end
end
