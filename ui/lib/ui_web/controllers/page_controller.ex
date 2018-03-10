defmodule UiWeb.PageController do
  use UiWeb, :controller

  def index(conn, _params) do
    {module, function} = Application.fetch_env!(:ui, :leds)
    apply(module, function, [])
    render conn, "index.html"
  end
end
