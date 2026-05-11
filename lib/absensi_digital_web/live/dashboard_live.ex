defmodule AbsensiDigitalWeb.DashboardLive do
  use AbsensiDigitalWeb, :live_view
  alias AbsensiDigital.Repo
  alias AbsensiDigital.Academy.AttendanceLog

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Dashboard mulai mendengarkan topik "attendance_logs"
      Phoenix.PubSub.subscribe(AbsensiDigital.PubSub, "attendance_logs")
    end

    {:ok, assign(socket, logs: fetch_today_logs())}
  end

  # Fungsi ini akan terpanggil otomatis saat ada broadcast {:new_log, log}
  def handle_info({:new_log, log}, socket) do
    # Masukkan log baru ke urutan paling atas daftar
    new_logs = [log | socket.assigns.logs]
    {:noreply, assign(socket, logs: new_logs)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-[1280px] mx-auto px-4 sm:px-6 lg:px-8 py-8 lg:py-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
      <header class="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-12">
        <div class="space-y-2">
          <h1 class="text-3xl md:text-4xl font-bold tracking-tight text-brand-on-surface">Dashboard</h1>
          <p class="text-brand-on-surface-variant text-base font-medium">
            Selamat datang kembali! Berikut adalah ringkasan absensi hari ini.
          </p>
        </div>
        
        <div class="flex items-center gap-4 bg-brand-surface-container-low p-2 rounded-brand-md border border-brand-outline-variant/30">
          <div class="px-3 py-1.5 bg-brand-primary/10 text-brand-primary rounded-brand-sm text-[10px] font-black tracking-[0.2em] flex items-center gap-2">
            <span class="relative flex h-2 w-2">
              <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-brand-primary opacity-75"></span>
              <span class="relative inline-flex rounded-full h-2 w-2 bg-brand-primary"></span>
            </span>
            LIVE MONITORING
          </div>
          <div class="text-xs font-bold text-brand-on-surface-variant pr-2">
            {Calendar.strftime(DateTime.now!("Asia/Jakarta"), "%d %B %Y")}
          </div>
        </div>
      </header>

      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
        <.stats_card
          title="Total Hadir"
          value={length(@logs)}
          icon="hero-check-badge"
          color="primary"
          trend="+12% vs Kemarin"
        />
        <.stats_card
          title="Siswa Aktif"
          value="42"
          icon="hero-users"
          color="secondary"
          trend="Semua Kelas Online"
        />
        <.stats_card
          title="Tepat Waktu"
          value="94%"
          icon="hero-clock"
          color="tertiary"
          trend="Performa Bagus"
        />
      </div>

      <!-- Recent Activity -->
      <div class="bg-brand-surface-container-lowest border border-brand-outline-variant/50 rounded-brand-lg overflow-hidden shadow-sm">
        <div class="px-8 py-8 border-b border-brand-outline-variant/30 flex flex-col sm:flex-row sm:items-center justify-between gap-6">
          <div>
            <h2 class="text-xl font-bold tracking-tight text-brand-on-surface">Aktivitas Terbaru</h2>
            <p class="text-sm font-medium text-brand-on-surface-variant mt-1">
              Data pemindaian siswa secara real-time
            </p>
          </div>
          <.button navigate={~p"/scan"} variant="primary" class="sm:w-auto w-full group">
            <span class="flex items-center justify-center gap-2">
              <.icon name="hero-qr-code" class="size-4 group-hover:scale-110 transition-transform" />
              Scan Baru
            </span>
          </.button>
        </div>

        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-brand-surface-container-low/50">
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Waktu</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Nama Siswa</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Kelas</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30 text-right">Status</th>
              </tr>
            </thead>
            <tbody id="attendance-logs" class="divide-y divide-brand-outline-variant/10">
              <%= for log <- @logs do %>
                <tr class="group hover:bg-brand-primary/5 odd:bg-brand-surface-container-lowest even:bg-brand-surface-container-low/30 transition-colors">
                  <td class="px-8 py-5 whitespace-nowrap">
                    <span class="text-sm font-semibold text-brand-on-surface/70 group-hover:text-brand-on-surface transition-colors">
                      {Calendar.strftime(
                        DateTime.from_naive!(log.inserted_at, "Etc/UTC")
                        |> DateTime.shift_zone!("Asia/Jakarta"),
                        "%H:%M:%S"
                      )}
                    </span>
                  </td>
                  <td class="px-8 py-5">
                    <div class="flex items-center gap-4">
                      <div class="size-10 rounded-brand-md bg-brand-surface-container-high flex items-center justify-center text-sm font-bold text-brand-on-surface-variant group-hover:bg-brand-primary/10 group-hover:text-brand-primary transition-all duration-300">
                        {String.slice(log.student.name, 0, 1)}
                      </div>
                      <span class="font-bold text-brand-on-surface group-hover:translate-x-1 transition-transform">
                        {log.student.name}
                      </span>
                    </div>
                  </td>
                  <td class="px-8 py-5">
                    <span class="text-sm font-medium text-brand-on-surface-variant">
                      {log.student.class.name}
                    </span>
                  </td>
                  <td class="px-8 py-5 text-right">
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-brand-full bg-brand-success/10 text-brand-success text-[10px] font-black uppercase tracking-widest border border-brand-success/20">
                      <span class="size-1.5 rounded-full bg-brand-success animate-pulse"></span>
                      {log.status}
                    </div>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>

          <div :if={@logs == []} class="py-24 text-center">
            <div class="size-16 bg-brand-surface-container rounded-brand-full flex items-center justify-center mx-auto mb-4">
              <.icon name="hero-inbox" class="size-8 text-brand-on-surface-variant/30" />
            </div>
            <p class="text-brand-on-surface-variant/50 font-bold uppercase tracking-widest text-xs">
              Belum ada absensi hari ini
            </p>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp stats_card(assigns) do
    colors = %{
      "primary" => "text-brand-primary bg-brand-primary/10",
      "secondary" => "text-brand-secondary bg-brand-secondary/10",
      "tertiary" => "text-brand-tertiary bg-brand-tertiary/10"
    }

    assigns = assign(assigns, :color_class, colors[assigns.color])

    ~H"""
    <div class="bg-brand-surface-container-lowest border border-brand-outline-variant/50 p-8 rounded-brand-lg group hover:border-brand-primary/30 transition-all duration-300 shadow-sm hover:shadow-md">
      <div class="flex items-center justify-between mb-8">
        <div class={["p-3 rounded-brand-md transition-transform duration-500 group-hover:scale-110", @color_class]}>
          <.icon name={@icon} class="size-6" />
        </div>
        <div class="px-2.5 py-1 rounded-brand-sm bg-brand-surface-container text-[10px] font-black uppercase tracking-widest text-brand-on-surface-variant">
          {@trend}
        </div>
      </div>
      <p class="text-xs font-black text-brand-on-surface-variant/60 uppercase tracking-[0.2em] mb-2">
        {@title}
      </p>
      <div class="text-4xl font-bold tracking-tight text-brand-on-surface">
        {@value}
      </div>
    </div>
    """
  end

  defp fetch_today_logs do
    AttendanceLog
    |> Repo.all()
    |> Repo.preload(student: :class)
    # Yang terbaru di atas
    |> Enum.sort_by(& &1.inserted_at, :desc)
  end
end
