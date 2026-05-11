defmodule AbsensiDigitalWeb.PageController do
  use AbsensiDigitalWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
