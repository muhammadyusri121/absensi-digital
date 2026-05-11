defmodule AbsensiDigitalWeb.Nav do
  import Phoenix.Component

  def on_mount(:set_current_scope, _params, _session, socket) do
    {:cont, assign_current_scope(socket)}
  end

  defp assign_current_scope(socket) do
    case socket.view do
      AbsensiDigitalWeb.DashboardLive -> assign(socket, :current_scope, :dashboard)
      AbsensiDigitalWeb.StudentLive -> assign(socket, :current_scope, :student)
      AbsensiDigitalWeb.ScanLive -> assign(socket, :current_scope, :scan)
      _ -> assign(socket, :current_scope, nil)
    end
  end
end
