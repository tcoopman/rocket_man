defmodule UiWeb.LedController do
    use UiWeb, :controller

    @leds_module Application.fetch_env!(:ui, :leds)

    def on(conn, _params) do
        apply(@leds_module, :turn_on, [])
        json conn, "ok"
    end

    def off(conn, _params) do
        apply(@leds_module, :turn_off, [])
        json conn, "ok"
    end
end