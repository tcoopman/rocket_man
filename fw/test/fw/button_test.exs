defmodule FwTest.ButtonTest do
  use ExUnit.Case

  import Mox

  alias Fw.Button

  setup :set_mox_global
  setup :verify_on_exit!

  setup do
    {:ok, _pid} = Registry.start_link(keys: :duplicate, name: :fw_pubsub)
    []
  end

  test "starting a button" do
    Fw.GPIO.Mock
    |> expect(:start_link, fn pin, direction ->
      assert 15 == pin
      assert :input == direction
      {:ok, self()}
    end)
    |> expect(:set_int, fn pid, int_direction ->
      assert pid == self()
      assert :both == int_direction
    end)

    assert {:ok, _pid} = Button.start_link(topic_name: "button", pin: 15)
  end

  test "pressing a button results in a received message" do
    topic = "button"
    Registry.register(:fw_pubsub, topic, [])

    Fw.GPIO.Mock
    |> stub(:start_link, fn _pin, _direction -> {:ok, self()} end)
    |> stub(:set_int, fn _pid, _int_direction -> nil end)

    {:ok, pid} = Button.start_link(topic_name: topic, pin: 15)

    send(pid, {:gpio_interrupt, nil, :rising})

    assert_receive_nb(1, :button_clicked)
  end

  test "there is some throttling on the button" do
    topic = "button"
    Registry.register(:fw_pubsub, topic, [])

    Fw.GPIO.Mock
    |> stub(:start_link, fn _pin, _direction -> {:ok, self()} end)
    |> stub(:set_int, fn _pid, _int_direction -> nil end)

    {:ok, pid} = Button.start_link(topic_name: topic, pin: 15)

    send(pid, {:gpio_interrupt, nil, :rising})
    send(pid, {:gpio_interrupt, nil, :rising})
    send(pid, {:gpio_interrupt, nil, :rising})

    assert_receive_nb(1, :button_clicked)

    Process.sleep(20)

    send(pid, {:gpio_interrupt, nil, :rising})

    assert_receive_nb(1, :button_clicked)
  end

  defp assert_receive_nb(nb, message) do
    receive do
      message ->
        if nb <= 0 do
          raise "#{message} receive too many times"
        else
          assert_receive_nb(nb - 1, message)
        end
    after
      1 ->
        if nb == 0 do
          :ok
        else
          raise "#{message} not received"
        end
    end
  end
end
