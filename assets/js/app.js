// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Html5Qrcode } from "html5-qrcode";
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/absensi_digital"
import topbar from "../vendor/topbar"

// --- BAGIAN HOOKS (TAMBAHKAN INI) ---
let Hooks = {}

Hooks.QrScanner = {
  mounted() {
    console.log("[QrScanner] Hook mounted.");
    console.log("[QrScanner] Checking Html5Qrcode class:", typeof Html5Qrcode);
    console.log("[QrScanner] Checking mediaDevices API:", typeof navigator.mediaDevices);

    const readerId = "reader";
    const html5QrCode = new Html5Qrcode(readerId);
    this.scanner = html5QrCode;

    const config = { 
      fps: 10, 
      qrbox: { width: 250, height: 250 } 
    };

    let isPaused = false;

    const startCamera = () => {
      // Clear any custom UI first
      const readerEl = document.getElementById(readerId);
      if (readerEl) readerEl.innerHTML = "";

      html5QrCode.start(
        { facingMode: "environment" },
        config,
        (decodedText) => {
          if (isPaused) return;
          
          console.log("[QrScanner] QR Scanned:", decodedText);
          isPaused = true;
          this.pushEvent("qr_scanned", { qr_data: decodedText });

          // Re-enable after 3 seconds
          setTimeout(() => {
            isPaused = false;
          }, 3000);
        },
        (error) => {
          // Scan noise - quiet
        }
      )
      .then(() => {
        console.log("[QrScanner] Camera started successfully.");
      })
      .catch((err) => {
        console.error("[QrScanner] Gagal mengaktifkan kamera:", err);
        showPermissionUI();
      });
    };

    const showPermissionUI = () => {
      const readerEl = document.getElementById(readerId);
      if (!readerEl) return;

      readerEl.innerHTML = `
        <div class="flex flex-col items-center justify-center h-full p-6 text-center space-y-5 animate-in fade-in duration-500">
          <div class="p-4 rounded-brand-md bg-brand-primary/10 text-brand-primary shadow-inner">
            <svg class="size-8 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
          </div>
          <div class="space-y-1">
            <p class="text-sm font-black text-brand-on-surface">Akses Kamera Diperlukan</p>
            <p class="text-[11px] font-bold text-brand-on-surface-variant/75 max-w-[200px] mx-auto leading-relaxed">
              Izinkan akses kamera pada perizinan browser Anda untuk mulai memindai.
            </p>
          </div>
          <button id="start-camera-btn" class="px-5 py-2.5 bg-brand-primary hover:bg-brand-primary-hover text-brand-on-primary rounded-brand-md font-extrabold text-xs shadow-md shadow-brand-primary/20 active:scale-95 transition-all">
            Aktifkan Kamera
          </button>
        </div>
      `;

      const btn = document.getElementById("start-camera-btn");
      if (btn) {
        btn.addEventListener("click", () => {
          startCamera();
        });
      }
    };

    // Auto-start on mount
    startCamera();

    this.handleEvent("play_sound", (data) => {
      console.log("[QrScanner] Playing sound:", data.type);
      const soundFile = data.type === "success" ? "/sounds/success.mp3" : "/sounds/error.mp3";
      const audio = new Audio(soundFile);
      audio.load();
      audio.play().catch(e => {
        console.warn("[QrScanner] Audio play failed (autoplay blocked):", e);
      });
    });
  },
  destroyed() {
    if (this.scanner) {
      this.scanner.stop().catch(err => {
        console.error("Failed to stop scanner on destroy:", err);
      });
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, ...Hooks} // <-- TAMBAHKAN BARIS INI SAJA
})

// 5. Connect
liveSocket.connect()


// connect if there are any LiveViews on the page
// liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

