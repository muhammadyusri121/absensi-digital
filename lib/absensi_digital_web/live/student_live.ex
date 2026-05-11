defmodule AbsensiDigitalWeb.StudentLive do
  use AbsensiDigitalWeb, :live_view
  alias AbsensiDigital.Academy

  alias AbsensiDigital.Academy.Student
  alias AbsensiDigitalWeb.CoreComponents

  def mount(_params, _session, socket) do
    students = Academy.list_students()
    classes = Academy.list_classes()

    {:ok,
     socket
     |> assign(students: students)
     |> assign(classes: classes)
     |> assign_form(Academy.Student.changeset(%Student{}, %{}))}
  end

  def handle_event("validate", %{"student" => student_params}, socket) do
    changeset =
      %Student{}
      |> Academy.Student.changeset(student_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"student" => student_params}, socket) do
    case Academy.create_student(student_params) do
      {:ok, _student} ->
        {:noreply,
         socket
         |> put_flash(:info, "Siswa berhasil ditambahkan!")
         |> push_patch(to: ~p"/student")
         |> assign(students: Academy.list_students())}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-[1280px] mx-auto px-4 sm:px-6 lg:px-8 py-8 lg:py-12 animate-in fade-in slide-in-from-bottom-4 duration-1000">
      <header class="flex flex-col md:flex-row md:items-end justify-between gap-8 mb-12">
        <div class="space-y-2">
          <h1 class="text-3xl md:text-4xl font-bold tracking-tight text-brand-on-surface">Data Siswa</h1>
          <p class="text-brand-on-surface-variant text-base font-medium">
            Kelola data dan status absensi siswa di sekolah.
          </p>
        </div>
        
        <div class="flex flex-col sm:flex-row items-center gap-4 w-full md:w-auto">
          <div class="relative group w-full sm:w-72">
            <div class="absolute inset-y-0 left-4 flex items-center pointer-events-none text-brand-on-surface-variant/50 group-focus-within:text-brand-primary transition-colors">
              <.icon name="hero-magnifying-glass" class="size-5" />
            </div>
            <input
              type="text"
              placeholder="Cari nama siswa..."
              class="w-full bg-brand-surface-container-low border border-brand-outline-variant/30 rounded-brand-md py-2.5 pl-12 pr-6 text-sm font-bold focus:outline-none focus:ring-2 focus:ring-brand-primary/20 focus:border-brand-primary transition-all shadow-sm"
            />
          </div>
          <.button phx-click={CoreComponents.show("#add-student-modal")} variant="primary" class="w-full sm:w-auto group">
            <span class="flex items-center justify-center gap-2">
              <.icon name="hero-plus" class="size-5 group-hover:rotate-90 transition-transform duration-300" />
              Tambah Siswa
            </span>
          </.button>
        </div>
      </header>

      <div class="bg-brand-surface-container-lowest border border-brand-outline-variant/50 rounded-brand-lg overflow-hidden shadow-sm">
        <div class="overflow-x-auto">
          <table class="w-full text-left border-collapse">
            <thead>
              <tr class="bg-brand-surface-container-low/50">
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Nama Siswa</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Kelas</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Token Pairing</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30">Status</th>
                <th class="px-8 py-4 text-[10px] font-black uppercase tracking-[0.2em] text-brand-on-surface-variant/70 border-b border-brand-outline-variant/30 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-brand-outline-variant/10">
              <%= for student <- @students do %>
                <tr class="group hover:bg-brand-primary/5 odd:bg-brand-surface-container-lowest even:bg-brand-surface-container-low/30 transition-colors">
                  <td class="px-8 py-6">
                    <div class="flex items-center gap-4">
                      <div class="size-11 rounded-brand-md bg-brand-surface-container-high flex items-center justify-center font-bold text-brand-primary group-hover:bg-brand-primary/10 transition-all duration-300">
                        {String.slice(student.name, 0, 1)}
                      </div>
                      <div>
                        <p class="font-bold text-brand-on-surface group-hover:translate-x-1 transition-transform">{student.name}</p>
                        <p class="text-[10px] text-brand-on-surface-variant font-bold uppercase tracking-widest mt-0.5">
                          ID: {String.slice(student.id, 0, 8)}
                        </p>
                      </div>
                    </div>
                  </td>
                  <td class="px-8 py-6">
                    <div class="inline-flex items-center gap-2 px-3 py-1 rounded-brand-sm bg-brand-surface-container text-[10px] font-black uppercase tracking-widest text-brand-on-surface-variant group-hover:bg-brand-primary/10 group-hover:text-brand-primary transition-colors">
                      <.icon name="hero-academic-cap" class="size-3" />
                      {student.class.name}
                    </div>
                  </td>
                  <td class="px-8 py-6">
                    <code class="px-3 py-1.5 rounded-brand-sm bg-brand-surface-container-low font-mono text-xs font-bold text-brand-on-surface-variant border border-brand-outline-variant/30 group-hover:border-brand-primary/20 transition-colors">
                      {student.pairing_token}
                    </code>
                  </td>
                  <td class="px-8 py-6">
                    <%= if student.is_paired do %>
                      <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-brand-full bg-brand-success/10 text-brand-success text-[10px] font-black uppercase tracking-widest border border-brand-success/20">
                        <span class="size-1.5 rounded-full bg-brand-success animate-pulse"></span>
                        PAIRED
                      </div>
                    <% else %>
                      <div class="inline-flex items-center gap-2 px-4 py-1.5 rounded-brand-full bg-brand-warning/10 text-brand-warning text-[10px] font-black uppercase tracking-widest border border-brand-warning/20">
                        <span class="size-1.5 rounded-full bg-brand-warning"></span> WAITING
                      </div>
                    <% end %>
                  </td>
                  <td class="px-8 py-6 text-right">
                    <button class="p-2 rounded-brand-md bg-brand-surface-container-lowest border border-brand-outline-variant/50 text-brand-on-surface-variant hover:text-brand-primary hover:border-brand-primary/30 transition-all shadow-sm">
                      <.icon name="hero-ellipsis-horizontal" class="size-5" />
                    </button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
          
          <div :if={@students == []} class="py-24 text-center">
            <div class="size-16 bg-brand-surface-container rounded-brand-full flex items-center justify-center mx-auto mb-4">
              <.icon name="hero-user-group" class="size-8 text-brand-on-surface-variant/30" />
            </div>
            <p class="text-brand-on-surface-variant/50 font-bold uppercase tracking-widest text-xs">
              Belum ada data siswa
            </p>
          </div>
        </div>
      </div>
    </div>

    <.modal id="add-student-modal">
      <:title>Tambah Siswa Baru</:title>
      <:subtitle>Lengkapi data di bawah ini untuk mendaftarkan siswa baru.</:subtitle>
      
      <.form for={@form} id="student-form" phx-change="validate" phx-submit="save">
        <div class="space-y-4">
          <.input field={@form[:name]} type="text" label="Nama Lengkap" placeholder="Contoh: Budi Santoso" />
          
          <.input
            field={@form[:class_id]}
            type="select"
            label="Kelas"
            options={Enum.map(@classes, &{&1.name, &1.id})}
            prompt="Pilih Kelas"
          />

          <.input
            field={@form[:pairing_token]}
            type="text"
            label="Token Pairing (Opsional)"
            placeholder="Biarkan kosong untuk generate otomatis"
          />
        </div>
        
        <div class="mt-8 flex justify-end">
          <.button variant="primary" class="w-full sm:w-auto">
            Simpan Data Siswa
          </.button>
        </div>
      </.form>
    </.modal>
    """
  end
end
