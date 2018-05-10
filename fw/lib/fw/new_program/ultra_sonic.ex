defmodule Fw.UltraSonic do
  @moduledoc """
  Module that can measure a HC-SR04 Ultrasonic Range Sensor

  https://www.modmypi.com/blog/hc-sr04-ultrasonic-range-sensor-on-the-raspberry-pi
  """
  use GenServer

  require Logger
  alias __MODULE__

  @gpio ElixirALE.GPIO

  @name __MODULE__

  def start_link(trig: trig, echo: echo) do
    GenServer.start_link(@name, [trig: trig, echo: echo], name: @name)
  end

  @impl GenServer
  def init(trig: trig, echo: echo) do
    {:ok, trig_pin} = @gpio.start_link(trig, :output)
    {:ok, echo_pin} = @gpio.start_link(echo, :input)
    setup()
    {:ok, {trig_pin, echo_pin}}
  end

  def measure() do
    GenServer.call(@name, :measure)
  end

  @impl GenServer
  def handle_call(:measure, _from, {trig_pin, echo_pin} = state) do
    task = Task.async(fn -> read(echo_pin) end)
    Process.sleep(60)
    @gpio.write(trig_pin, 1)
    Process.sleep(1)
    @gpio.write(trig_pin, 0)

    {result, :ok} = Task.await(task, 500)
    distance = 34_300 / 2 * result / 1_000_000
    Logger.info(result, label: "result")
    Logger.info(distance, label: "distance")

    {:reply, distance, state}
  end

  @impl GenServer
  def handle_info(:setup, {trig_pin, _} = state) do
    @gpio.write(trig_pin, 0)
    Process.sleep(2_000)
    Logger.info("setup done")
    {:noreply, state}
  end

  def setup() do
    Process.send_after(self(), :setup, 1)
  end

  defp read(echo_pin) do
    case @gpio.read(echo_pin) do
      0 -> read(echo_pin)
      1 -> :timer.tc(UltraSonic, :time_result, [echo_pin])
    end
  end

  def time_result(echo_pin) do
    case @gpio.read(echo_pin) do
      1 -> time_result(echo_pin)
      0 -> :ok
    end
  end
end
