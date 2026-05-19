# Gemini Agent Instructions — Sistem Absensi Phoenix

> Dokumen ini adalah panduan perilaku wajib untuk AI agent yang bekerja pada proyek ini.
> Baca dan patuhi seluruh instruksi sebelum menulis satu baris kode pun.

---

## 0. Identitas Proyek

- **Framework**: Phoenix Framework (Elixir)
- **Render Layer**: Phoenix LiveView + PWA
- **Database**: PostgreSQL (via Ecto)
- **Integrasi Eksternal**: WhatsApp Gateway (notifikasi orang tua)
- **Target pengguna**: Guru, Admin TU, Kepala Sekolah, Orang Tua (pasif via WA)
- **Bahasa kode**: Elixir (backend), HTML/CSS/JS minimal (frontend LiveView)
- **Bahasa dokumentasi & komentar**: Bahasa Indonesia untuk komentar bisnis, English untuk komentar teknis

---

## 1. Prinsip Utama (Non-Negotiable)

Setiap keputusan kode harus memenuhi keempat pilar ini secara bersamaan. Jika ada konflik antar pilar, prioritasnya adalah: **Keamanan → Keterbacaan → Efisiensi → Kerapian**.

```
SECURITY  >  READABILITY  >  EFFICIENCY  >  CLEANLINESS
```

Jangan pernah mengorbankan keamanan demi kecepatan pengembangan, dan jangan pernah menulis kode yang "bekerja tapi tidak bisa dibaca orang lain".

---

## 2. Keamanan (Security)

### 2.1 Autentikasi & Otorisasi

- Gunakan `mix phx.gen.auth` sebagai fondasi autentikasi. Jangan buat sistem auth dari nol.
- Setiap route yang memerlukan login **wajib** dilindungi plug `:require_authenticated_user`.
- Implementasikan **Role-Based Access Control (RBAC)** dengan roles: `admin`, `kepala_sekolah`, `guru`, `wali_kelas`.
- Buat plug reusable untuk validasi role:

  ```elixir
  # lib/absensi_web/plugs/require_role.ex
  defmodule AbsensiWeb.Plugs.RequireRole do
    @moduledoc "Memastikan user memiliki role yang diizinkan sebelum mengakses resource."
    import Plug.Conn
    import Phoenix.Controller

    def init(roles), do: roles

    def call(conn, roles) do
      if conn.assigns.current_user.role in roles do
        conn
      else
        conn |> put_flash(:error, "Akses tidak diizinkan.") |> redirect(to: "/") |> halt()
      end
    end
  end
  ```

- LiveView: validasi otorisasi di `mount/3`, bukan hanya di router. Jangan percaya bahwa router sudah cukup.

### 2.2 Input Validation & Sanitasi

- **Selalu** gunakan Ecto Changeset untuk validasi data. Jangan pernah insert/update data tanpa melalui changeset.
- Gunakan `Ecto.Changeset.validate_*` secara eksplisit — jangan hanya mengandalkan constraint database.
- Untuk input teks bebas (nama, keterangan): gunakan `cast/3` dan batasi panjang karakter dengan `validate_length/3`.
- Jangan pernah interpolasi input user langsung ke dalam query Ecto. Selalu gunakan parameter binding.

  ```elixir
  # ❌ JANGAN
  Repo.query("SELECT * FROM students WHERE name = '#{name}'")

  # ✅ BENAR
  from(s in Student, where: s.name == ^name) |> Repo.all()
  ```

### 2.3 Data Sensitif

- Nomor WhatsApp orang tua adalah data sensitif. Jangan pernah log nomor WA dalam plaintext.
- Gunakan `Logger.metadata` untuk struktural logging, bukan `IO.inspect` di production.
- Environment variables wajib menggunakan `System.fetch_env!/1` (bukan `System.get_env/1`) agar aplikasi gagal dengan pesan jelas saat config tidak ditemukan.
- Semua secret (API key WA Gateway, DB password) disimpan di `.env` dan **tidak pernah** di-commit ke repository. Tambahkan `.env` ke `.gitignore`.

### 2.4 CSRF & XSS

- Phoenix sudah menyediakan CSRF token secara default — jangan nonaktifkan.
- Untuk LiveView forms, selalu gunakan `<.form>` component bawaan Phoenix yang sudah CSRF-safe.
- Jangan gunakan `raw/1` pada output yang berasal dari input user.

### 2.5 Rate Limiting

- Terapkan rate limiting pada endpoint autentikasi (login, reset password) menggunakan library `Hammer` atau `ExRated`.
- WhatsApp Gateway endpoint wajib di-rate-limit untuk mencegah spam notifikasi.

### 2.6 Dependency Security

- Jalankan `mix hex.audit` secara berkala untuk memeriksa dependency dengan kerentanan yang diketahui.
- Selalu pin versi dependency di `mix.exs`. Jangan gunakan `>= x.x` tanpa batas atas.

---

## 3. Keterbacaan & Dokumentasi (Readability)

### 3.1 Module Documentation

Setiap module **wajib** memiliki `@moduledoc` yang menjelaskan:
- Apa yang dilakukan module ini
- Siapa yang menggunakannya (context bisnis)
- Dependensi penting jika ada

```elixir
defmodule Absensi.Kehadiran do
  @moduledoc """
  Context untuk mengelola data kehadiran murid.

  Module ini adalah satu-satunya entry point untuk semua operasi
  yang berkaitan dengan pencatatan, pembaruan, dan pelaporan absensi.
  Dipanggil oleh LiveView layer dan background job notifikasi WA.
  """
end
```

### 3.2 Function Documentation

Setiap fungsi publik wajib memiliki `@doc` dan `@spec`:

```elixir
@doc """
Mencatat kehadiran murid untuk hari ini.

Mengembalikan `{:ok, kehadiran}` jika berhasil, atau
`{:error, changeset}` jika validasi gagal.

## Parameter
- `attrs` - Map berisi `murid_id`, `kelas_id`, `status`, `dicatat_oleh`

## Contoh
    iex> catat_kehadiran(%{murid_id: 1, status: :hadir})
    {:ok, %Kehadiran{}}
"""
@spec catat_kehadiran(map()) :: {:ok, Kehadiran.t()} | {:error, Ecto.Changeset.t()}
def catat_kehadiran(attrs) do
  %Kehadiran{}
  |> Kehadiran.changeset(attrs)
  |> Repo.insert()
end
```

### 3.3 Penamaan

- Gunakan nama yang deskriptif dan mencerminkan domain bisnis sekolah.
- Variabel: `snake_case`. Module: `PascalCase`. Konstanta/atom: `snake_case`.
- Hindari singkatan ambigu. Gunakan `murid_id` bukan `mid`, `kelas_id` bukan `kid`.
- Nama fungsi harus mencerminkan aksi: `catat_kehadiran/1`, `kirim_notifikasi_wa/2`, `rekap_bulanan/2`.

### 3.4 Struktur Kode

- Maksimal **panjang fungsi: 20 baris**. Jika lebih, pecah menjadi fungsi-fungsi privat.
- Maksimal **panjang file: 250 baris** (kecuali schema atau migration).
- Gunakan pattern matching dan guard clause untuk menggantikan if-else berlapis.

  ```elixir
  # ❌ HINDARI
  def proses_status(status) do
    if status == "hadir" do
      ...
    else
      if status == "izin" do
        ...
      end
    end
  end

  # ✅ GUNAKAN
  def proses_status(:hadir), do: ...
  def proses_status(:izin), do: ...
  def proses_status(:sakit), do: ...
  def proses_status(:alpha), do: ...
  ```

### 3.5 Komentar

- Komentar menjelaskan **mengapa**, bukan **apa**. Kode yang baik sudah menjelaskan "apa".
- Gunakan komentar bisnis untuk logika domain yang tidak intuitif:

  ```elixir
  # Murid dianggap alpha jika tidak ada record kehadiran
  # hingga 30 menit setelah jam masuk. Ref: SOP Sekolah Pasal 12.
  def alpha?(murid_id, tanggal) do
    ...
  end
  ```

---

## 4. Efisiensi (Performance & Memory)

### 4.1 Database Queries

- **Selalu** preload asosiasi yang dibutuhkan dalam satu query. Hindari N+1 query.

  ```elixir
  # ❌ N+1 — menyebabkan 1 query per murid
  murid_list = Repo.all(Murid)
  Enum.map(murid_list, fn m -> Repo.preload(m, :kelas) end)

  # ✅ Satu query dengan join
  Murid |> preload(:kelas) |> Repo.all()
  ```

- Gunakan `Repo.stream/2` untuk memproses dataset besar (rekap bulanan, export Excel) agar tidak memuat semua data ke memori sekaligus.
- Selalu tambahkan index di kolom yang sering digunakan dalam `WHERE`, `JOIN`, dan `ORDER BY`. Wajib untuk: `murid_id`, `kelas_id`, `tanggal`, `status`.
- Gunakan `select/2` untuk mengambil hanya kolom yang diperlukan, bukan `SELECT *`.

  ```elixir
  from(k in Kehadiran,
    where: k.tanggal == ^today,
    select: %{murid_id: k.murid_id, status: k.status}
  ) |> Repo.all()
  ```

### 4.2 LiveView Efficiency

- Minimalkan data yang disimpan di `socket.assigns`. Simpan hanya yang dirender.
- Gunakan `update/3` untuk memperbarui assigns secara inkremental, bukan `assign/3` untuk seluruh state.
- Gunakan `phx-update="stream"` untuk list yang besar dan sering berubah (daftar murid, activity feed).
- Pisahkan komponen yang jarang berubah ke `stateless functional component` agar tidak re-render sia-sia.

### 4.3 Background Jobs

- Pengiriman notifikasi WhatsApp **wajib** dijalankan sebagai background job menggunakan `Oban`. Jangan pernah mengirim WA secara synchronous dalam request/response cycle.
- Konfigurasi Oban dengan retry dan dead letter queue:

  ```elixir
  # config/config.exs
  config :absensi, Oban,
    repo: Absensi.Repo,
    queues: [notifikasi_wa: 10, laporan: 2],
    plugins: [Oban.Plugins.Pruner]
  ```

### 4.4 Caching

- Cache data yang jarang berubah (daftar kelas, data murid per kelas) menggunakan `ETS` atau `:persistent_term` untuk akses O(1).
- Invalidasi cache ketika data master diperbarui.

### 4.5 Memory

- Gunakan atom hanya untuk nilai yang terbatas dan sudah diketahui di compile-time (status kehadiran, roles). Jangan convert string arbitrary dari user menjadi atom (`String.to_atom/1` dilarang — gunakan `String.to_existing_atom/1`).
- Gunakan binary pattern matching untuk parsing data WA response daripada regex apabila memungkinkan.

---

## 5. Kerapian & Struktur Proyek (Cleanliness)

### 5.1 Arsitektur Context

Ikuti Phoenix Context pattern secara ketat. Setiap domain bisnis punya context-nya sendiri:

```
lib/absensi/
├── akun/           # User, Role, Session
├── akademik/       # Kelas, MataPelajaran, TahunAjaran
├── kehadiran/      # Absensi, Rekap, Status
├── murid/          # Data murid, wali
├── notifikasi/     # WA Gateway, template pesan
└── laporan/        # Export Excel, PDF, agregasi data
```

- **Dilarang** memanggil `Repo` langsung dari LiveView atau Controller. Semua akses data harus melalui Context.
- **Dilarang** memanggil satu context dari context lain secara langsung. Gunakan publik API antar context.

### 5.2 Prinsip DRY (Don't Repeat Yourself)

- Sebelum menulis fungsi baru, **cari dulu** apakah fungsi serupa sudah ada di context yang relevan.
- Logika yang dipakai lebih dari satu tempat **wajib** di-extract ke modul tersendiri atau fungsi privat yang dishare.
- Gunakan Phoenix Component (`~H` heex components) untuk UI yang berulang: badge status, avatar murid, kartu ringkasan.

  ```elixir
  # lib/absensi_web/components/ui_components.ex
  attr :status, :atom, required: true
  def status_badge(assigns) do
    ~H"""
    <span class={["badge", badge_class(@status)]}>
      <%= label_status(@status) %>
    </span>
    """
  end
  ```

- Jangan duplikasi query. Gunakan `Ecto.Query` composition:

  ```elixir
  defp filter_aktif(query), do: from(q in query, where: q.aktif == true)
  defp filter_kelas(query, kelas_id), do: from(q in query, where: q.kelas_id == ^kelas_id)

  # Digunakan di mana saja
  Murid |> filter_aktif() |> filter_kelas(kelas_id) |> Repo.all()
  ```

### 5.3 Formatting

- Wajib jalankan `mix format` sebelum setiap commit. Tidak ada exception.
- Gunakan `.formatter.exs` yang konsisten di seluruh project.
- Konfigurasi `Credo` untuk static analysis:

  ```elixir
  # .credo.exs
  %{
    configs: [%{
      name: "default",
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Refactor.Nesting, max_nesting: 3},
          {Credo.Check.Refactor.FunctionArity, max_arity: 5},
        ]
      }
    }]
  }
  ```

### 5.4 Testing

- Setiap fungsi publik di Context **wajib** memiliki unit test.
- Gunakan `ExMachina` untuk factory data test — jangan buat data fixture secara manual berulang kali.
- Pisahkan test: `test/unit/`, `test/integration/`, `test/live_view/`.
- Minimal coverage target: **80%** untuk context layer.

  ```elixir
  # test/absensi/kehadiran_test.exs
  describe "catat_kehadiran/1" do
    test "berhasil mencatat kehadiran dengan data valid" do
      murid = insert(:murid)
      assert {:ok, kehadiran} = Kehadiran.catat_kehadiran(%{murid_id: murid.id, status: :hadir})
      assert kehadiran.status == :hadir
    end

    test "gagal jika murid_id tidak ditemukan" do
      assert {:error, changeset} = Kehadiran.catat_kehadiran(%{murid_id: 999, status: :hadir})
      assert "does not exist" in errors_on(changeset).murid_id
    end
  end
  ```

---

## 6. Konvensi Khusus Proyek Ini

### 6.1 Istilah Domain (Wajib Konsisten)

| Konteks | Gunakan | Jangan Gunakan |
|---|---|---|
| Peserta didik | `murid` | `siswa`, `student` |
| Kehadiran | `kehadiran` | `attendance`, `absen` |
| Pencatatan absen | `catat_kehadiran` | `record_attendance` |
| Status | `:hadir`, `:izin`, `:sakit`, `:alpha` | string seperti `"present"` |
| Notifikasi | `notifikasi` | `notification` |
| Kelas | `kelas` | `class`, `classroom` |

### 6.2 Status Kehadiran

Gunakan atom, bukan string atau integer:

```elixir
# Di schema
field :status, Ecto.Enum, values: [:hadir, :izin, :sakit, :alpha]
```

### 6.3 Logging

Gunakan level log yang tepat:
- `Logger.debug/1` — detail internal saat development
- `Logger.info/1` — event bisnis penting (absensi dicatat, notifikasi terkirim)
- `Logger.warning/1` — kondisi tidak normal tapi tidak fatal (retry WA gagal)
- `Logger.error/1` — kegagalan yang memerlukan perhatian segera

```elixir
Logger.info("Kehadiran dicatat", murid_id: murid.id, status: status, oleh: user.id)
Logger.warning("Pengiriman WA gagal, akan retry", murid_id: murid.id, attempt: attempt)
```

### 6.4 Error Handling

- Selalu gunakan tagged tuple `{:ok, result}` / `{:error, reason}` untuk fungsi yang bisa gagal.
- Gunakan `with` untuk chaining operasi yang bisa gagal, bukan nested case:

  ```elixir
  def proses_absensi(attrs) do
    with {:ok, murid}     <- cari_murid(attrs.murid_id),
         {:ok, kehadiran} <- catat_kehadiran(murid, attrs),
         {:ok, _job}      <- jadwalkan_notifikasi(murid, kehadiran) do
      {:ok, kehadiran}
    else
      {:error, :murid_tidak_ditemukan} -> {:error, "Murid tidak terdaftar dalam sistem."}
      {:error, changeset}              -> {:error, changeset}
    end
  end
  ```

---

## 7. Workflow Pengembangan

### 7.1 Sebelum Menulis Kode

Sebelum agent mulai menulis kode untuk sebuah fitur, agent **wajib**:
1. Identifikasi context mana yang akan terpengaruh
2. Cek apakah ada fungsi yang sudah ada dan bisa digunakan kembali
3. Rancang signature fungsi dan struct yang akan digunakan
4. Baru mulai implementasi

### 7.2 Checklist Setiap Kode yang Ditulis

Sebelum menyerahkan kode kepada developer, agent harus memverifikasi:

- [ ] Apakah ada logika duplikat dengan kode yang sudah ada?
- [ ] Apakah semua fungsi publik punya `@doc` dan `@spec`?
- [ ] Apakah semua module punya `@moduledoc`?
- [ ] Apakah input divalidasi sebelum diproses?
- [ ] Apakah tidak ada query N+1?
- [ ] Apakah operasi berat (WA, export) dijalankan sebagai background job?
- [ ] Apakah akses data melalui Context, bukan langsung ke Repo dari LiveView?
- [ ] Apakah kode sudah `mix format` compliant?
- [ ] Apakah ada unit test untuk fungsi publik yang baru ditambahkan?

### 7.3 Migrasi Database

- Setiap migrasi **wajib** bisa di-rollback (`down/0` harus diimplementasikan).
- Tambahkan index di migrasi yang sama dengan pembuatan tabel, bukan migrasi terpisah.
- Nama migrasi harus deskriptif: `create_table_kehadiran`, bukan `update_table`.
- Jangan ubah migrasi yang sudah pernah dijalankan di production. Buat migrasi baru.

---

## 8. Yang Dilarang Keras (Hard Rules)

Agent **tidak boleh** melakukan hal-hal berikut dalam kondisi apapun:

```
❌ Menggunakan IO.inspect di luar sesi debugging lokal
❌ Menyimpan password atau API key dalam source code
❌ Menggunakan String.to_atom/1 pada input dari user/database
❌ Memanggil Repo langsung dari LiveView atau Controller
❌ Mengirim notifikasi WA secara synchronous
❌ Menulis fungsi tanpa @doc dan @spec (untuk fungsi publik)
❌ Membuat fungsi duplikat tanpa memeriksa yang sudah ada
❌ Menggunakan raw SQL string interpolation
❌ Menonaktifkan CSRF protection
❌ Commit file .env atau file berisi secret apapun
```

---

*Dokumen ini adalah living document. Perbarui jika ada keputusan arsitektur baru yang disepakati oleh tim.*