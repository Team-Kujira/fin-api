defmodule FinApi.TradingView do
  import Ecto.Query

  def truncate(%NaiveDateTime{} = datetime, "1") do
    d = NaiveDateTime.truncate(datetime, :second)
    %{d | second: 0}
  end

  def truncate(%NaiveDateTime{} = datetime, "3") do
    datetime
    |> truncate("1")
    |> Map.update!(:minute, &(&1 - rem(&1, 3)))
  end

  def truncate(%NaiveDateTime{} = datetime, "5") do
    datetime
    |> truncate("1")
    |> Map.update!(:minute, &(&1 - rem(&1, 5)))
  end

  def truncate(%NaiveDateTime{} = datetime, "15") do
    datetime
    |> truncate("1")
    |> Map.update!(:minute, &(&1 - rem(&1, 15)))
  end

  def truncate(%NaiveDateTime{} = datetime, "30") do
    datetime
    |> truncate("1")
    |> Map.update!(:minute, &(&1 - rem(&1, 30)))
  end

  def truncate(%NaiveDateTime{} = datetime, "60") do
    datetime
    |> truncate("1")
    |> Map.put(:minute, 0)
  end

  def truncate(%NaiveDateTime{} = datetime, "120") do
    datetime
    |> truncate("60")
    |> Map.update!(:hour, &(&1 - rem(&1, 2)))
  end

  def truncate(%NaiveDateTime{} = datetime, "180") do
    datetime
    |> truncate("60")
    |> Map.update!(:hour, &(&1 - rem(&1, 3)))
  end

  def truncate(%NaiveDateTime{} = datetime, "240") do
    datetime
    |> truncate("60")
    |> Map.update!(:hour, &(&1 - rem(&1, 4)))
  end

  def truncate(%NaiveDateTime{} = datetime, "1D") do
    datetime
    |> truncate("60")
    |> Map.put(:hour, 0)
  end

  def truncate(%NaiveDateTime{} = datetime, "1M") do
    datetime
    |> truncate("1D")
    |> Map.put(:day, 1)
  end

  def truncate(%NaiveDateTime{} = datetime, "12M") do
    datetime
    |> truncate("1M")
    |> Map.put(:month, 1)
  end

  def with_range(q, from, to, "1") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin + '1 minute'::interval * -1 min, bin max from generate_series(?::timestamp, ?::timestamp, '1 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "3") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '3 minute' max from generate_series(?::timestamp, ?::timestamp, '3 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "5") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '5 minute' max from generate_series(?::timestamp, ?::timestamp, '5 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "15") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '15 minute' max from generate_series(?::timestamp, ?::timestamp, '15 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "30") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '30 minute' max from generate_series(?::timestamp, ?::timestamp, '30 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "60") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '60 minute' max from generate_series(?::timestamp, ?::timestamp, '60 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "120") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '120 minute' max from generate_series(?::timestamp, ?::timestamp, '120 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "180") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '180 minute' max from generate_series(?::timestamp, ?::timestamp, '180 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "240") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '240 minute' max from generate_series(?::timestamp, ?::timestamp, '240 minute') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "1D") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '1 day' max from generate_series(?::timestamp, ?::timestamp, '1 day') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "1M") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '1 month' max from generate_series(?::timestamp, ?::timestamp, '1 month') bin",
          ^from,
          ^to
        )
    )
  end

  def with_range(q, from, to, "12M") do
    with_cte(q, "bins",
      as:
        fragment(
          "SELECT bin min, bin + '1 year' max from generate_series(?::timestamp, ?::timestamp, '1 year') bin",
          ^from,
          ^to
        )
    )
  end
end
