defmodule TzdataSqlite do
  @moduledoc """
  tzdata baked by sqlite with only actively used tzs held in memory
  """

  require Logger

  # TODO use something like latest.db
  def download_db do
    {:ok, conn} = Mint.HTTP.connect(:https, "github.com", 443)

    {:ok, conn, ref} =
      Mint.HTTP.request(
        conn,
        "GET",
        "/ruslandoga/tzdata_sqlite/releases/download/2022a/tzdata_2022a.db",
        [],
        nil
      )

    # TODO
    File.rm("tzdata_2022a.db.part")
    {:ok, fd} = File.open("tzdata_2022a.db.part", [:binary, :append])
    %{status: 302, headers: headers} = request(conn, ref, %{})

    location =
      :proplists.get_value("location", headers, nil) || raise "didn't find location in headers"

    %URI{host: host, path: path, query: query} = URI.parse(location)
    Mint.HTTP.close(conn)

    {:ok, conn} = Mint.HTTP.connect(:https, host, 443)
    {:ok, conn, ref} = Mint.HTTP.request(conn, "GET", path <> "?" <> query, [], nil)
    %{status: 200} = request(conn, ref, %{fd: fd})
    :ok = File.close(fd)
    File.rename!("tzdata_2022a.db.part", "tzdata_2022a.db")

    # TODO
    TzdataSqlite.Repo.start_link(database: "tzdata_2022a.db")
  end

  defp request(conn, ref, state) do
    receive do
      message ->
        case Mint.HTTP.stream(conn, message) do
          :unknown ->
            _ = Logger.error(fn -> "Received unknown message: " <> inspect(message) end)
            request(conn, ref, state)

          {:ok, conn, responses} ->
            case process_responses(responses, ref, state) do
              {:cont, state} -> request(conn, ref, state)
              {:done, state} -> state
            end
        end
    end
  end

  defp process_responses([{:status, ref, status} | rest], ref, state),
    do: process_responses(rest, ref, Map.put(state, :status, status))

  defp process_responses([{:headers, ref, headers} | rest], ref, state),
    do: process_responses(rest, ref, Map.put(state, :headers, headers))

  defp process_responses([{:data, ref, data} | rest], ref, state) do
    :ok = IO.binwrite(state.fd, data)
    process_responses(rest, ref, state)
  end

  defp process_responses([{:done, ref}], ref, state), do: {:done, state}
  defp process_responses([], _ref, state), do: {:cont, state}
end
