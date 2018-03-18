defmodule Fw.GPIO do
  @type pin_direction :: :input | :output
  @callback start_link(integer, pin_direction) :: {:ok, pid}

  @type int_direction :: :rising | :falling | :both | :none
  @callback set_int(pid, int_direction) :: :ok | {:error, term}
end
