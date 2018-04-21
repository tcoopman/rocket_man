defmodule Fw.NewProgram do
  require Logger
  use GenServer

  @state_off :off
  @state_regular :regular
  @state_trigger :trigger
  @state_cool_down :cool_down

  defmodule Options do
    @enforce_keys [
      :measurement_topic,
      :button_topic
    ]
    defstruct @enforce_keys
  end

  alias __MODULE__

  def start_link(%NewProgram.Options{} = opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    Registry.register(:fw_pubsub, opts.measurement_topic, [])
    Registry.register(:fw_pubsub, opts.button_topic, [])
    {:ok, @state_off}
  end

  @impl GenServer
  def handle_info(:button_clicked, @state_off) do
    Logger.info("received :button_clicked in state #{@state_off}")
    Fw.Executer.load_program(Fw.Programs.Regular)

    {:noreply, @state_regular}
  end

  @impl GenServer
  def handle_info(:button_clicked, state) do
    Logger.info("received :button_clicked in state #{state}")
    Fw.Executer.stop()

    {:noreply, @state_off}
  end

  @impl GenServer
  def handle_info({:distance, distance}, @state_regular) when distance < 20 do
    Logger.info("received :distance: #{distance} in state #{@state_regular}")
    Fw.Executer.load_program(Fw.Programs.Walker)
    Process.send_after(self(), :cooldown, 5_000)

    {:noreply, @state_trigger}
  end

  @impl GenServer
  def handle_info(:cooldown, @state_trigger) do
    Logger.info("received :cooldown in state #{@state_trigger}")

    Fw.Executer.load_program(Fw.Programs.Regular)
    Process.send_after(self(), :cooldown, 5_000)
    {:noreply, @state_cool_down}
  end

  @impl GenServer
  def handle_info(:cooldown, @state_cool_down) do
    Logger.info("received :cooldown in state #{@state_cool_down}")

    {:noreply, @state_regular}
  end

  @impl GenServer
  def handle_info(msg, state) do
    Logger.info("received #{inspect(msg)} in state #{state} - doing nothing")

    {:noreply, state}
  end
end
