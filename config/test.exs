import Config
config :fin, remote_supervisor: fn(_recipient) -> Fin.TaskSupervisor end
