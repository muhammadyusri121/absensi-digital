defmodule AbsensiDigitalWeb.ScanLive do
  use AbsensiDigitalWeb, :live_view
  alias AbsensiDigital.Student, as: StudentContext

  def mount(_params, _session, socket) do
    {:ok, assign(socket, last_student: nil, error: nil)}
  end

  @spec handle_event(<<_::80>>, map(), any()) :: {:noreply, map()}
  def handle_event("qr_scanned", %{"qr_data" => data}, socket) do
    case StudentContext.get_student_by_qr(data) do
      nil ->
        {:noreply,
         socket
         |> put_flash(:error, "QR Code tidak dikenali!")
         |> assign(last_student: nil)
         |> push_event("play_sound", %{type: "error"})}

      student ->
        # Simpan ke database
        case StudentContext.record_attendance(student) do
          {:ok, _log} ->
            {:noreply,
             socket
             |> put_flash(:info, "Presensi berhasil dicatat!")
             |> assign(last_student: student)
             |> push_event("play_sound", %{type: "success"})}

          {:error, _} ->
            {:noreply,
             socket
             |> assign(error: "Gagal menyimpan data!")
             |> push_event("play_sound", %{type: "error"})}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto space-y-10 animate-in zoom-in-95 duration-700">
      <header class="text-center space-y-2">
        <div class="inline-flex p-3 rounded-brand-md bg-brand-primary-container text-brand-primary mb-2 shadow-lg shadow-brand-primary/10">
          <.icon name="hero-qr-code" class="size-8" />
        </div>
        <h1 class="text-3xl font-black tracking-tight text-brand-on-surface">QR Attendance</h1>
        <p class="text-brand-on-surface-variant font-bold text-sm uppercase tracking-widest text-balance">
          Scan your student card to record your attendance today
        </p>
      </header>

      <div class="relative group">
        <!-- Decorative elements -->
        <div class="absolute -inset-4 bg-gradient-to-tr from-brand-primary/20 via-brand-secondary/20 to-brand-primary/20 rounded-brand-lg blur-2xl opacity-30 group-hover:opacity-60 transition-opacity duration-1000">
        </div>

        <div class="relative bg-brand-surface-container-low/80 backdrop-blur-2xl border border-brand-outline-variant rounded-brand-lg p-8 shadow-2xl overflow-hidden">
          <div class="aspect-square relative rounded-brand-md overflow-hidden border-2 border-dashed border-brand-outline-variant group-hover:border-brand-primary transition-colors duration-500 bg-brand-background/40">
            <div
              id="reader"
              phx-update="ignore"
              phx-hook="QrScanner"
              class="w-full h-full object-cover"
            >
            </div>

    <!-- Scan Overlay -->
            <div class="absolute inset-0 pointer-events-none flex flex-col items-center justify-center">
              <div class="size-64 border-2 border-brand-primary/20 rounded-brand-md relative">
                <div class="absolute top-0 left-0 size-8 border-t-4 border-l-4 border-brand-primary rounded-tl-brand-sm">
                </div>
                <div class="absolute top-0 right-0 size-8 border-t-4 border-r-4 border-brand-primary rounded-tr-brand-sm">
                </div>
                <div class="absolute bottom-0 left-0 size-8 border-b-4 border-l-4 border-brand-primary rounded-bl-brand-sm">
                </div>
                <div class="absolute bottom-0 right-0 size-8 border-b-4 border-r-4 border-brand-primary rounded-br-brand-sm">
                </div>

                <div class="absolute inset-x-0 h-1 bg-gradient-to-r from-transparent via-brand-primary to-transparent animate-[scan_2.5s_ease-in-out_infinite] top-0 shadow-[0_0_20px_rgba(var(--color-brand-primary),0.8)]">
                </div>
              </div>
            </div>
          </div>

          <div id="result" class="mt-8 min-h-[100px] flex items-center justify-center">
            <%= if @last_student do %>
              <div class="w-full animate-in slide-in-from-top-4 duration-500">
                <div class="bg-brand-success-container border border-brand-success/20 rounded-brand-md p-6 flex items-center gap-6 shadow-xl shadow-brand-success/10">
                  <div class="size-16 rounded-brand-md bg-brand-success text-brand-on-success flex items-center justify-center shadow-lg">
                    <.icon name="hero-check" class="size-10" />
                  </div>
                  <div>
                    <p class="text-[10px] font-black text-brand-on-success-container uppercase tracking-[0.2em] mb-1">
                      Success Recorded
                    </p>
                    <h3 class="text-2xl font-black tracking-tight text-brand-on-success-container">
                      {@last_student.name}
                    </h3>
                    <p class="text-xs font-bold text-brand-on-success-container/60 uppercase tracking-widest">
                      {@last_student.class.name}
                    </p>
                  </div>
                </div>
              </div>
            <% else %>
              <%= if @error do %>
                <div class="w-full animate-in shake duration-500">
                  <div class="bg-brand-error-container border border-brand-error/20 rounded-brand-md p-6 flex items-center gap-6 shadow-xl shadow-brand-error/10">
                    <div class="size-16 rounded-brand-md bg-brand-error text-brand-on-error flex items-center justify-center shadow-lg">
                      <.icon name="hero-x-mark" class="size-10" />
                    </div>
                    <div>
                      <p class="text-[10px] font-black text-brand-on-error-container uppercase tracking-[0.2em] mb-1">
                        Error Occurred
                      </p>
                      <h3 class="text-xl font-black tracking-tight text-brand-on-error-container">
                        {@error}
                      </h3>
                    </div>
                  </div>
                </div>
              <% else %>
                <div class="text-center py-4">
                  <p class="text-[10px] font-black text-brand-on-surface-variant/40 uppercase tracking-[0.2em] italic">
                    Position the QR code within the frame to scan
                  </p>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>

      <footer class="flex items-center justify-center gap-8 text-brand-on-surface-variant/30 font-black text-[10px] uppercase tracking-[0.2em]">
        <div class="flex items-center gap-2">
          <.icon name="hero-shield-check" class="size-4" /> Secure Scan
        </div>
        <div class="flex items-center gap-2">
          <.icon name="hero-bolt" class="size-4" /> Real-time Sync
        </div>
      </footer>
    </div>

    <style>
      @keyframes scan {
        0% { transform: translateY(0); opacity: 0; }
        10% { opacity: 1; }
        90% { opacity: 1; }
        100% { transform: translateY(256px); opacity: 0; }
      }
    </style>
    """
  end
end
