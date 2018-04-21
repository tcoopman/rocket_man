defmodule Fw.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    new_program_options = %Fw.NewProgram.Options{
      button_topic: "button17",
      measurement_topic: "measurement"
    }

    # Define workers and child supervisors to be supervised
    children = [
      {Registry, [keys: :duplicate, name: :fw_pubsub]},
      {Fw.Dotstar, [speed_hz: 8_000_000]},
      {Fw.Button, [topic_name: "button17", pin: 17]},
      {Fw.NewProgram, new_program_options},
      {Fw.Executer, []},
      supervisor(Supervisor, Fw.MeasureDistance.supervisor(1000, "measurement"))
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
