import Config
config :fin, remote_supervisor: fn(recipient) -> {Fin.TaskSupervisor, recipient} end
