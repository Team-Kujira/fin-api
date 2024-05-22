defmodule FinApi.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades, primary_key: false) do
      add(:height, :integer, primary_key: true)
      add(:tx_idx, :integer, primary_key: true)
      add(:idx, :integer, primary_key: true)
      add(:contract, :text, null: false)
      add(:txhash, :string, null: false)
      add(:quote_amount, :numeric, null: false)
      add(:base_amount, :numeric, null: false)
      add(:price, :decimal, null: false)
      add(:type, :string)
      add(:protocol, :string)
      add(:timestamp, :naive_datetime_usec, null: false)

      timestamps(type: :utc_datetime_usec)
    end

    create index(:trades, [:contract])
    create index(:trades, [:timestamp])
    create index(:trades, [:txhash])
    create index(:trades, [:quote_amount])
    create index(:trades, [:base_amount])
    create index(:trades, [:price])
    create index(:trades, [:type])
    create index(:trades, [:protocol])
  end
end
