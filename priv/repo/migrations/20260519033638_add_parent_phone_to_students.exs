defmodule AbsensiDigital.Repo.Migrations.AddParentPhoneToStudents do
  use Ecto.Migration

  def change do
    alter table(:students) do
      add :parent_phone, :string
    end
  end
end
