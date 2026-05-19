defmodule AbsensiDigital.Student do
  @moduledoc """
  Konteks Student: Menyediakan API internal untuk mengelola data
  Kelas (Classes) dan Siswa (Students).
  """

  import Ecto.Query, warn: false
  alias AbsensiDigital.Repo
  alias AbsensiDigital.Student.Class
  alias AbsensiDigital.Student.Student, as: StudentModel
  alias AbsensiDigital.Student.AttendanceLog

  # ==========================================
  # LOGIKA KELAS (CLASSES)
  # ==========================================

  @doc "Mengambil semua daftar kelas."
  def list_classes do
    Repo.all(Class)
  end

  @doc "Mengambil satu kelas berdasarkan ID."
  def get_class!(id), do: Repo.get!(Class, id)

  @doc "Membuat kelas baru."
  def create_class(attrs \\ %{}) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
  end

  def record_attendance(student) do
    %AttendanceLog{}
    |> AttendanceLog.changeset(%{student_id: student.id, status: "hadir"})
    |> Repo.insert()
    |> case do
      {:ok, log} ->
        # Broadcast data ke topik "attendance_logs"
        log_with_data = Repo.preload(log, student: :class)

        Phoenix.PubSub.broadcast(
          AbsensiDigital.PubSub,
          "attendance_logs",
          {:new_log, log_with_data}
        )

        # Kirim notifikasi WA Orang Tua (Asinkron)
        parent_phone = log_with_data.student.parent_phone
        student_name = log_with_data.student.name
        class_name = log_with_data.student.class.name

        AbsensiDigital.Services.WhatsApp.send_attendance_notification(
          student_name,
          class_name,
          parent_phone
        )

        {:ok, log_with_data}

      error ->
        error
    end
  end

  # ==========================================
  # LOGIKA SISWA (STUDENTS)
  # ==========================================

  @doc "Mengambil semua daftar siswa beserta data kelasnya."
  def list_students do
    StudentModel
    |> Repo.all()
    # Memuat data kelas agar tidak muncul #Ecto.Association.NotLoaded
    |> Repo.preload(:class)
  end

  @doc "Mengambil satu siswa berdasarkan ID."
  def get_student!(id), do: Repo.get!(StudentModel, id)

  @doc "Mencari siswa berdasarkan kode QR (digunakan saat scanning)."
  def get_student_by_qr(qr_data) do
    StudentModel
    |> where([s], s.qr_code_data == ^qr_data or s.pairing_token == ^qr_data)
    |> Repo.one()
    |> Repo.preload(:class)
  end

  @doc "Mencari siswa berdasarkan token pairing (digunakan oleh wali murid)."
  def get_student_by_token(token) do
    Repo.get_by(StudentModel, pairing_token: token)
  end

  @doc "Membuat siswa baru."
  def create_student(attrs \\ %{}) do
    %StudentModel{}
    |> StudentModel.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Mengupdate data siswa."
  def update_student(%StudentModel{} = student, attrs) do
    student
    |> StudentModel.changeset(attrs)
    |> Repo.update()
  end

  @doc "Menghapus data siswa."
  def delete_student(%StudentModel{} = student) do
    Repo.delete(student)
  end

  @doc "Mengubah status pairing siswa menjadi true."
  def verify_student_pairing(student_id) do
    student = get_student!(student_id)

    student
    |> StudentModel.changeset(%{is_paired: true})
    |> Repo.update()
  end
end
