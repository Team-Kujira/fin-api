defmodule FinApiWeb.ContractsController do
  use FinApiWeb, :controller

  def index(conn, _) do
    with {:ok, contracts} <- Kujira.Fin.list_pairs(FinApi.Node.channel()) do
      json(conn, contracts)
    end
  end
end
