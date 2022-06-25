defmodule TzdataSqlite.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [TzdataSqlite.Repo]
    Supervisor.start_link(children, strategy: :one_for_one, name: TzdataSqlite.Supervisor)
  end
end
