defmodule AbsensiDigital.Student.Class do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "classes" do
    field :name, :string
    has_many :students, AbsensiDigital.Student.Student
    timestamps()
  end

  def changeset(class, attrs) do
    class |> cast(attrs, [:name]) |> validate_required([:name])
  end
end
