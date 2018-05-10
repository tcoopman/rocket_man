defmodule Fw.Button do
  use GenServer
  require Logger

  @button_ignore_time Application.fetch_env!(:fw, :button_ignore_time)

  @doc """
  Starts a new button listener on `gpio` port.

  It will send a `:button_clicked` message to all topics registered under `topic_name`
  """
  def start_link([topic_name: _, pin: _] = opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(topic_name: topic_name, pin: pin) do
    {:ok, gpio} = GPIO.open(pin, :input)
    :ok = GPIO.set_edge_mode(gpio, :both)
    {:ok, %{gpio: gpio, topic_name: topic_name, ignore: false}}
  end

  @impl GenServer
  def handle_info({:gpio, _, _, 1}, %{topic_name: topic_name, ignore: false} = state) do
    Logger.info("dispatching click")
    Registry.dispatch(:fw_pubsub, topic_name, fn entries ->
      for {pid, _} <- entries, do: send(pid, :button_clicked)
    end)

    state = %{state | ignore: true}
    start_ignore_timer()

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:gpio, _pin_number, _timestamp, 0}, state), do: {:noreply, state}

  @impl GenServer
  def handle_info({:gpio, _, _, _}, %{ignore: true} = state), do: {:noreply, state}

  @impl GenServer
  def handle_info(:lift_ignore, state) do
    {:noreply, %{state | ignore: false}}
  end

  defp start_ignore_timer() do
    Process.send_after(self(), :lift_ignore, @button_ignore_time)
  end
end
