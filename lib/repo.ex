defmodule TzdataSqlite.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.SQLite3, otp_app: :tzdata_sqlite
end
