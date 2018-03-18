defmodule FwTest.ColorTest do
  use ExUnit.Case, async: true

  alias Fw.Color

  test "Transition" do
    assert [%Color.RGBA{}, %Color.RGBA{}] = Color.transition(2)
  end
end
