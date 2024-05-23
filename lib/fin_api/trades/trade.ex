defmodule FinApi.Trades.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  @moduledoc """
  A normalized Trade event. Primary key is on the (height, tx_idx, idx) tuple
  """

  @primary_key false
  schema "trades" do
    field :height, :integer, primary_key: true
    field :tx_idx, :integer, primary_key: true
    field :idx, :integer, primary_key: true

    field :contract, :string
    field :txhash, :string
    field :quote_amount, :decimal
    field :base_amount, :decimal
    field :price, :decimal
    field :type, :string
    field :protocol, :string
    field :timestamp, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(trade, params) do
    trade
    |> cast(params, [
      :height,
      :tx_idx,
      :idx,
      :contract,
      :txhash,
      :quote_amount,
      :base_amount,
      :price,
      :type,
      :protocol,
      :timestamp
    ])
    |> validate_required([
      :height,
      :tx_idx,
      :idx,
      :contract,
      :txhash,
      :quote_amount,
      :base_amount,
      :price,
      :type,
      :protocol,
      :timestamp
    ])
    |> unique_constraint([:height, :tx_idx, :idx], name: "trades_pkey")
  end
end
