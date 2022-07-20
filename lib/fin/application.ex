defmodule Fin.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: Fin.TaskSupervisor},
      # {Fin.RBCState, %{echo: true, vote: true, index: 0}},
      # DAG
    ]

    opts = [strategy: :one_for_one, name: Fin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
