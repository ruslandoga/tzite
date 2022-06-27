defmodule TzDB do
  @moduledoc "Implements the `Calendar.TimeZoneDatabase` behaviour."
  @behaviour Calendar.TimeZoneDatabase

  @impl true
  def time_zone_period_from_utc_iso_days(_iso_days, "Etc/UTC") do
    {:ok, %{std_offset: 0, utc_offset: 0, zone_abbr: "UTC", wall_period: {:min, :max}}}
  end
end
