defmodule AbsensiDigital.Student.AttendanceLog do
  use Ecto.Schema
  import Ecto.Changeset

  # Kita gunakan binary_id (UUID) agar konsisten dengan tabel lainnya
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "attendance_logs" do
    field :status, :string, default: "hadir"

    # Menghubungkan log ini dengan satu siswa
    belongs_to :student, AbsensiDigital.Student.Student

    # Ini otomatis mencatat inserted_at (waktu scan)
    timestamps()
  end

  @doc """
  Changeset untuk memvalidasi data sebelum masuk ke database.
  """
  def changeset(attendance_log, attrs) do
    attendance_log
    |> cast(attrs, [:status, :student_id])
    |> validate_required([:status, :student_id])
  end
end
