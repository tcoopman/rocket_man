defmodule Fw.MeasureDistance do
  use GenServer

  defmodule Options do
    @enforce_keys [:interval, :topic]
    defstruct @enforce_keys
  end

  alias Fw.UltraSonic
  alias __MODULE__

  def supervisor(interval, topic) do
    ultra_sonic_config = Application.fetch_env!(:fw, :layout)[:ultrasonic]

    measure_distance_options = %Fw.MeasureDistance.Options{
      interval: interval,
      topic: topic
    }

    children = [
      {Fw.UltraSonic, ultra_sonic_config},
      {Fw.MeasureDistance, measure_distance_options}
    ]

    [children, [strategy: :one_for_one]]
  end

  def start_link(%MeasureDistance.Options{} = options) do
    GenServer.start_link(__MODULE__, options)
  end

  @impl GenServer
  def init(options) do
    schedule_measurement(options.interval)
    {:ok, options}
  end

  @impl GenServer
  def handle_info(:measure, state) do
    distance = UltraSonic.measure()

    Registry.dispatch(:fw_pubsub, state.topic, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:distance, distance})
    end)

    schedule_measurement(state.interval)
    {:noreply, state}
  end

  defp schedule_measurement(time) do
    Process.send_after(self(), :measure, time)
  end
end
