defmodule FinApi.Trades do
  @moduledoc """
  Individual trades executed on Kujira FIN
  """
  alias FinApi.Repo
  alias FinApi.Trades.Trade
  import Ecto.Query

  @spec all_trades(non_neg_integer(), :asc | :desc) :: [Trade.t()]
  def all_trades(limit \\ 100, sort \\ :desc) do
    Trade
    |> sort(sort)
    |> limit(^limit)
    |> Repo.all()
  end

  @spec list_trades(String.t(), non_neg_integer(), :asc | :desc) :: [Trade.t()]
  def list_trades(contract, limit \\ 100, sort \\ :desc) do
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

  def sort(query, dir) do
    order_by(query, [x], [
      {^dir, x.height},
      {^dir, x.tx_idx},
      {^dir, x.idx}
    ])
  end
end
