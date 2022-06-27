`experiment` tzdata baked by sqlite with only actively used tzs held in memory

How it works:

- `nightly on github` a new sqlite database with iana timezone info is built and [released](https://github.com/ruslandoga/tzdata_sqlite/releases/)
- `in the app` the sqlite database is downloaded and connection to it is opened
- [`in elixir`](https://hexdocs.pm/elixir/1.13/Calendar.TimeZoneDatabase.html) when a function like `DateTime.new!(Date.utc_today, ~T[00:00:00], "Europe/Moscow")` is called, timezone info is fetched from sqlite and cached in-memory

```elixir
iex> TzdataSqlite.download_db()
# {:ok, #PID<0.292.0>}

iex> DateTime.new!(Date.utc_today, ~T[00:00:00], "Europe/Moscow")
# #DateTime<2022-06-27 00:00:00+03:00 MSK Europe/Moscow>
```

TODO:

- [x] periodically build tzdata sqlite db in github actions (TODO remove hardcoded values, switch away tfrom tzdata for preprocessing)
- [x] download sqlite db from github
- [ ] lz4 or gzip db
- [x] read from sqlite with no sqlite cache
- [ ] store actively used tzs in memory
