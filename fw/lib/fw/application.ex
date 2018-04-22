defmodule Fw.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    button_topic = "button_on_off"
    measurement_topic = "measurement"

    new_program_options = %Fw.NewProgram.Options{
      button_topic: button_topic,
      measurement_topic: measurement_topic
    }

    # Define workers and child supervisors to be supervised
    children = [
      {Registry, [keys: :duplicate, name: :fw_pubsub]},
      {Fw.Dotstar, [speed_hz: 8_000_000]},
      {Fw.Button, [topic_name: button_topic, pin: 17]},
      {Fw.NewProgram, new_program_options},
      {Fw.Executer, []},
      supervisor(Supervisor, Fw.MeasureDistance.supervisor(1000, measurement_topic))
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Fw.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
