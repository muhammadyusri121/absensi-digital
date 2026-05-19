defmodule AbsensiDigital.Services.WhatsApp do
  @moduledoc """
  Layanan integrasi API WhatsApp menggunakan Fonnte Gateway.
  Mendukung simulasi log lokal untuk testing tanpa token di Development.
  """

  require Logger

  @doc """
  Mengirimkan notifikasi presensi siswa ke nomor WhatsApp orang tua secara asinkron.
  """
  def send_attendance_notification(student_name, class_name, phone_number) do
    if is_nil(phone_number) or String.trim(phone_number) == "" do
      Logger.warning("[WhatsApp Service] Lewati pengiriman WA karena nomor telepon kosong.")
      :ok
    else
      # Dapatkan waktu saat ini di WIB (UTC+7)
      wib_time = DateTime.utc_now() |> DateTime.add(7, :hour)
      date_str = Calendar.strftime(wib_time, "%A, %d %B %Y")
      time_str = Calendar.strftime(wib_time, "%H:%M")

      message = """
      Yth. Bapak/Ibu Wali Murid dari *#{student_name}*,

      Kami menginformasikan bahwa putra/putri Anda telah melakukan presensi masuk di sekolah pada hari ini:

      📅 Hari/Tanggal: *#{date_str}*
      ⏰ Waktu: *#{time_str} WIB*
      🏫 Kelas: *#{class_name}*
      🟢 Status: *HADIR*

      Terima kasih atas perhatian Bapak/Ibu.
      --
      *Sistem Absensi Digital Sekolah*
      """

      # Jalankan pengiriman dalam background Task agar tidak memblokir antarmuka UI Scanner
      Task.start(fn ->
        deliver_message(phone_number, message)
      end)

      :ok
    end
  end

  defp deliver_message(phone, message) do
    token = Application.get_env(:absensi_digital, :fonnte_token)

    if is_nil(token) or token == "" or token == "MOCK_TOKEN" do
      # Mode testing / pembangunan jika token belum diset
      Logger.info("""

      =========================================================
      📲 [WA API SIMULASI SIMULASI]
      Penerima WA: #{phone}
      Pesan:
      ---------------------------------------------------------
      #{message}
      =========================================================
      *Catatan: Atur :fonnte_token di config/dev.exs untuk mengirim pesan asli.*
      """)

      {:ok, :mocked}
    else
      # Mode produksi / kirim asli menggunakan Fonnte API
      url = "https://api.fonnte.com/send"

      body = %{
        target: phone,
        message: message,
        # Default kode negara Indonesia jika nomor diawali 08
        countryCode: "62"
      }

      headers = [
        {"Authorization", token}
      ]

      case Req.post(url, json: body, headers: headers) do
        {:ok, %Req.Response{status: 200, body: %{"status" => true} = resp}} ->
          Logger.info("[WhatsApp Service] WA sukses terkirim ke #{phone}. Resp: #{inspect(resp)}")
          {:ok, :sent}

        {:ok, %Req.Response{status: status, body: body}} ->
          Logger.error(
            "[WhatsApp Service] WA gagal dikirim ke #{phone}. Status: #{status}. Body: #{inspect(body)}"
          )

          {:error, :api_error}

        {:error, reason} ->
          Logger.error("[WhatsApp Service] HTTP request error ke Fonnte: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end
end
