alias Exqlite.Sqlite3

Mix.install([:tzdata, :exqlite])
tzdata = :ets.tab2list(:tzdata_rel_2022a)
{:ok, conn} = Sqlite3.open("tzdata_2022a_2.db")

:ok =
  Sqlite3.execute(
    conn,
    "create table tzdata (key, from_utc int, from_wall int, from_standard int, until_utc int, until_wall int, until_standard int, utc_off int, std_off int, zone_abbr)"
  )

{:ok, stmt} = Sqlite3.prepare(conn, "insert into tzdata values (?,?,?,?,?,?,?,?,?,?)")
:ok = Sqlite3.execute(conn, "begin")

Enum.each(tzdata, fn
  {_, _, _, _, _, _, _, _, _, _} = row ->
    :ok = Sqlite3.bind(conn, stmt, Tuple.to_list(row))
    :done = Sqlite3.step(conn, stmt)

  unmatched ->
    IO.inspect(unmatched, label: "unmatched")
end)

:ok = Sqlite3.execute(conn, "commit")
:ok = Sqlite3.release(conn, stmt)
:ok = Sqlite3.close(conn)
