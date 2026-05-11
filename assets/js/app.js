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
import { Html5QrcodeScanner } from "html5-qrcode";
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/absensi_digital"
import topbar from "../vendor/topbar"

// --- BAGIAN HOOKS (TAMBAHKAN INI) ---
let Hooks = {}

Hooks.QrScanner = {
  mounted() {
    import("html5-qrcode").then(module => {
      const scanner = new module.Html5QrcodeScanner("reader", { 
        fps: 10, 
        qrbox: { width: 250, height: 250 } 
      });

      this.scanner = scanner;
      this.scanner.render((decodedText) => {
        this.pushEvent("qr_scanned", { qr_data: decodedText });
        this.scanner.pause(true);
        setTimeout(() => this.scanner.resume(), 3000);
      });

      this.handleEvent("play_sound", (data) => {
        const soundFile = data.type === "success" ? "/sounds/success.mp3" : "/sounds/error.mp3";
        const audio = new Audio(soundFile);
        audio.load();
        audio.play().catch(e => {
          console.error("Audio play failed:", e);
          // Jika gagal karena autoplay policy, kita bisa beri pesan di console
          if (e.name === "NotAllowedError") {
            console.warn("Autoplay diblokir. Silakan klik di mana saja pada halaman terlebih dahulu.");
          }
        });
      });
    });
  },
  destroyed() {
    if (this.scanner) this.scanner.clear();
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

