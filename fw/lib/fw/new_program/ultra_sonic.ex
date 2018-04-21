defmodule Fw.UltraSonic do
  @moduledoc """
  Module that can measure a HC-SR04 Ultrasonic Range Sensor

  https://www.modmypi.com/blog/hc-sr04-ultrasonic-range-sensor-on-the-raspberry-pi
  """
  use GenServer

  require Logger
  alias __MODULE__

  @gpio Application.fetch_env!(:ale, :gpio)

  @name __MODULE__

  def start_link(trig: trig, echo: echo) do
    GenServer.start_link(@name, [trig: trig, echo: echo], name: @name)
  end

  @impl GenServer
  def init(trig: trig, echo: echo) do
    {:ok, trig_pid} = @gpio.start_link(trig, :output)
    {:ok, echo_pid} = @gpio.start_link(echo, :input)
    setup()
    {:ok, {trig_pid, echo_pid}}
  end

  def measure() do
    GenServer.call(@name, :measure)
  end

  @impl GenServer
  def handle_call(:measure, _from, {trig_pid, echo_pid} = state) do
    task = Task.async(fn -> read(echo_pid) end)
    Process.sleep(60)
    @gpio.write(trig_pid, 1)
    Process.sleep(1)
    @gpio.write(trig_pid, 0)

    {result, :ok} = Task.await(task, 500)
    distance = 34_300 / 2 * result / 1_000_000

    {:reply, distance, state}
  end

  @impl GenServer
  def handle_info(:setup, {trig_pid, _} = state) do
    @gpio.write(trig_pid, 0)
    Process.sleep(2_000)
    Logger.info("setup done")
    {:noreply, state}
  end

  def setup() do
    Process.send_after(self(), :setup, 1)
  end

  defp read(echo_pid) do
    case @gpio.read(echo_pid) do
      0 -> read(echo_pid)
      1 -> :timer.tc(UltraSonic, :time_result, [echo_pid])
    end
  end

  def time_result(echo_pid) do
    case @gpio.read(echo_pid) do
      1 -> time_result(echo_pid)
      0 -> :ok
    end
  end
end
