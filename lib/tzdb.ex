defmodule TzDB do
  @moduledoc "Implements the `Calendar.TimeZoneDatabase` behaviour."
  @behaviour Calendar.TimeZoneDatabase
  alias TzdataSqlite.Repo

  @impl true
  def time_zone_period_from_utc_iso_days(_iso_days, "Etc/UTC") do
    {:ok, %{std_offset: 0, utc_offset: 0, zone_abbr: "UTC"}}
  end

  def time_zone_period_from_utc_iso_days(iso_days, time_zone) do
    iso_days
    |> to_gregorian_seconds()
    |> period_from_utc_gregorian_seconds(time_zone)
  end

  @impl true
  def time_zone_periods_from_wall_datetime(_naive, "Etc/UTC") do
    {:ok, %{std_offset: 0, utc_offset: 0, zone_abbr: "UTC"}}
  end

  def time_zone_periods_from_wall_datetime(
        %NaiveDateTime{calendar: Calendar.ISO} = naive,
        time_zone
      ) do
    naive
    |> naive_to_gregorian_seconds()
    |> periods_from_wall_gregorian_seconds(time_zone)
  end

  # private

  # https://github.com/hrzndhrn/time_zone_info/blob/8cbe080e824b9a3c0bbde874ec1147074a9357da/lib/time_zone_info/iso_days.ex#L16
  @seconds_per_day 24 * 60 * 60
  @microseconds_per_second 1_000_000
  @parts_per_day @seconds_per_day * @microseconds_per_second

  defp to_gregorian_seconds({days, {parts_in_day, @parts_per_day}}) do
    div(days * @parts_per_day + parts_in_day, @microseconds_per_second)
  end

  import Ecto.Query

  # SELECT * FROM tzdata WHERE key = 'Europe/Moscow' AND from_utc > 63823532246 ORDER BY from_utc LIMIT 1;
  defp period_from_utc_gregorian_seconds(gregorian_seconds, time_zone) do
    "tzdata"
    |> where(key: ^time_zone)
    |> where([t], t.from_utc < ^gregorian_seconds)
    |> select([t], [t.std_off, t.utc_off, t.zone_abbr])
    |> limit(1)
    |> order_by([t], desc: :from_utc)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :time_zone_not_found}

      [std_offset, utc_offset, zone_abbr] ->
        {:ok, %{std_offset: std_offset, utc_offset: utc_offset, zone_abbr: zone_abbr}}
    end
  end

  defp periods_from_wall_gregorian_seconds(at_wall_seconds, time_zone) do
    "tzdata"
    |> where(key: ^time_zone)
    |> where([t], t.from_utc < ^at_wall_seconds)
    |> select([t], [t.std_off, t.utc_off, t.zone_abbr])
    |> limit(1)
    |> order_by([t], desc: :from_utc)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :time_zone_not_found}

      [std_offset, utc_offset, zone_abbr] ->
        {:ok, %{std_offset: std_offset, utc_offset: utc_offset, zone_abbr: zone_abbr}}
    end
  end

  defp naive_to_gregorian_seconds(%NaiveDateTime{calendar: Calendar.ISO, year: year})
       when year < 0,
       do: 0

  defp naive_to_gregorian_seconds(naive) do
    naive
    |> NaiveDateTime.to_erl()
    |> :calendar.datetime_to_gregorian_seconds()
  end
end
