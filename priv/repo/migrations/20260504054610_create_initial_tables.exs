defmodule SistemPresensi.Repo.Migrations.CreateInitialTables do
  use Ecto.Migration

  def change do
    # 1. Tabel Classes
    create table(:classes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :major, :string
      timestamps()
    end

    # 2. Tabel Students
    create table(:students, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :pairing_token, :string, null: false
      add :qr_code_data, :text, null: false
      add :is_paired, :boolean, default: false, null: false
      add :class_id, references(:classes, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create unique_index(:students, [:pairing_token])
    create index(:students, [:class_id])

    # 3. Tabel Guardians (Wali Murid)
    create table(:guardians, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :whatsapp_number, :string
      add :is_verified, :boolean, default: false, null: false
      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:guardians, [:student_id])
    create unique_index(:guardians, [:whatsapp_number, :student_id])

    # 4. Tabel Attendance Logs
    create table(:attendance_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string, default: "hadir"
      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:attendance_logs, [:student_id])
    create index(:attendance_logs, [:inserted_at])
  end
end
