defmodule Exekiel do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Exekiel.PoolManager}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
