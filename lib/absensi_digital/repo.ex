defmodule AbsensiDigital.Repo do
  use Ecto.Repo,
    otp_app: :absensi_digital,
    adapter: Ecto.Adapters.Postgres
end
