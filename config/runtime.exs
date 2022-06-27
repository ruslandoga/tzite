import Config

config :tzdata_sqlite, TzdataSqlite.Repo, database: "tzdata_2022a_2.db", cache_size: 0

if config_env() == :dev do
  config :elixir, time_zone_database: TzDB
end
