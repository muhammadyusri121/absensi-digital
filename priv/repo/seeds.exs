alias AbsensiDigital.Repo
alias AbsensiDigital.Academy.Class
alias AbsensiDigital.Academy.Student

# Bersihkan data lama agar tidak duplikat saat dijalankan ulang
Repo.delete_all(Student)
Repo.delete_all(Class)

# 1. Tambah Kelas
{:ok, kelas_rpl} = Repo.insert(%Class{name: "XII RPL 1"})
{:ok, kelas_tkj} = Repo.insert(%Class{name: "XII TKJ 2"})

# 2. Tambah Siswa
students = [
  %{
    name: "Yusri Muhammad",
    class_id: kelas_rpl.id,
    pairing_token: "XY1234",
    qr_code_data: "STD-XY1234",
    is_paired: false
  },
  %{
    name: "Budi Santoso",
    class_id: kelas_tkj.id,
    pairing_token: "TKJ001",
    qr_code_data: "STD-TKJ001",
    is_paired: true
  }
]

Enum.each(students, fn data ->
  %Student{}
  |> Student.changeset(data)
  |> Repo.insert!()
end)

IO.puts("✅ Data Berhasil Dimasukkan!")
