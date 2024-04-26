defmodule FinApiWeb.ContractsController do
  use FinApiWeb, :controller

  def show(conn, %{"id" => id, "book" => limit}) do
    with {limit, ""} <- Integer.parse(limit),
         {:ok, contract} <- Kujira.Fin.get_pair(FinApi.Node.channel(), id),
         {:ok, contract} <- Kujira.Fin.load_pair(FinApi.Node.channel(), contract, limit) do
      json(conn, contract)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, contract} <- Kujira.Fin.get_pair(FinApi.Node.channel(), id) do
      json(conn, contract)
    end
  end

  def index(conn, _) do
    with {:ok, contracts} <- Kujira.Fin.list_pairs(FinApi.Node.channel()) do
      json(conn, contracts)
    end
  end
end
