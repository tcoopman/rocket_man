defmodule Fw.HardwareGPIO do
  @behaviour Fw.GPIO

  alias ElixirALE.GPIO

  def start_link(pin, pin_direction), do: GPIO.start_link(pin, pin_direction)

  def set_int(pid, int_direction), do: GPIO.set_int(pid, int_direction)
end
