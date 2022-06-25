defmodule TzdataSqlite do
  @moduledoc """
  tzdata baked by sqlite with only actively used tzs held in memory
  """

  require Logger

  def download_tzdata do
    {:ok, conn} = Mint.HTTP.connect(:https, "data.iana.org", 443)
    {:ok, conn, ref} = Mint.HTTP.request(conn, "GET", "/time-zones/tzdata-latest.tar.gz", [], nil)
    state = download_tzdata_loop(conn, ref, %{})
    {:ok, _conn} = Mint.HTTP.close(conn)

    case state do
      %{status: 200, headers: headers, data: data} ->
        case :proplists.get_value("content-type", headers) do
          "application/x-gzip" ->
            :zlib.gunzip(data)
        end
    end
  end

  defp download_tzdata_loop(conn, ref, state) do
    receive do
      message ->
        case Mint.HTTP.stream(conn, message) do
          :unknown ->
            _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
            download_tzdata_loop(conn, ref, state)

          {:ok, conn, responses} ->
            case process_responses(responses, ref, state) do
              {:cont, state} -> download_tzdata_loop(conn, ref, state)
              {:done, state} -> state
            end
        end
    end
  end

  defp process_responses([{:status, ref, status} | rest], ref, state),
    do: process_responses(rest, ref, Map.put(state, :status, status))

  defp process_responses([{:headers, ref, headers} | rest], ref, state),
    do: process_responses(rest, ref, Map.put(state, :headers, headers))

  defp process_responses([{:data, ref, data} | rest], ref, state),
    do: process_responses(rest, ref, Map.update(state, :data, data, fn prev -> prev <> data end))

  defp process_responses([{:done, ref}], ref, state), do: {:done, state}
  defp process_responses([], _ref, state), do: {:cont, state}
end
