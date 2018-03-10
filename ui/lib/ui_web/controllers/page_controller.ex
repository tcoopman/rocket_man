defmodule UiWeb.PageController do
  use UiWeb, :controller

  def index(conn, _params) do
    module = Application.fetch_env!(:ui, :leds)
    apply(module, :turn_off, [])
    render conn, "index.html"
  end
end
