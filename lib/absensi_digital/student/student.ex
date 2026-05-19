defmodule AbsensiDigital.Student.Student do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "students" do
    field :name, :string
    field :pairing_token, :string
    field :qr_code_data, :string
    field :is_paired, :boolean, default: false
    field :parent_phone, :string

    # Relasi ke Kelas
    belongs_to :class, AbsensiDigital.Student.Class

    timestamps()
  end

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :pairing_token, :qr_code_data, :is_paired, :class_id, :parent_phone])
    |> validate_required([:name, :class_id])
    |> maybe_generate_pairing_token()
    |> maybe_generate_qr_code_data()
  end

  defp maybe_generate_pairing_token(changeset) do
    if get_field(changeset, :pairing_token) in [nil, ""] do
      put_change(changeset, :pairing_token, generate_random_token(6))
    else
      changeset
    end
  end

  defp maybe_generate_qr_code_data(changeset) do
    if get_field(changeset, :qr_code_data) in [nil, ""] do
      # For new students, we can use a temporary unique identifier or wait until insert
      # However, for simplicity, we'll generate a random suffix
      put_change(changeset, :qr_code_data, "STD-#{generate_random_token(12)}")
    else
      changeset
    end
  end

  defp generate_random_token(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.encode32(padding: false)
    |> String.slice(0, len)
  end
end
