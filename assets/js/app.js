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

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { TurnstileHook } from "phoenix_turnstile";

import { computePosition,flip, shift, autoUpdate } from '@floating-ui/dom'

import { register as swiperRegister } from "swiper/element/bundle";
import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode";
import { confetti } from "@tsparticles/confetti";

swiperRegister();

let html5QrCode;
const scanConfig = {
  fps: 2,
  rememberLastUserCamera: true,
  qrbox: { width: 200, height: 200 },
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    Turnstile: TurnstileHook,
    DropdownButton: {
      mounted() {
        const dropdown = this.el.querySelector("[data-dropdown]")
        this.cleanup = autoUpdate(this.el, dropdown, () => {
          computePosition(this.el, dropdown, {
            middleware: [flip(), shift({padding: 5})]}
          ).then(({x, y}) => {
            Object.assign(dropdown.style, {
              left: `${x}px`,
              top: `${y}px`
            })
          })
        })
      },
      destroyed() {
        this.cleanup?.()
      }
    },
    Confetti: {
      async mounted() {
        setTimeout(() => confetti("confetti"), 200);
      },
    },
    QrScannerInfo: {
      mounted() {
        Html5Qrcode.getCameras().then((cameras) => {
          this.pushEvent("cameras", cameras);
        });
      },
    },
    QrScanner: {
      mounted() {
        const cameraId = this.el.getAttribute("camera-id");
        html5QrCode = new Html5Qrcode("scanner", {
          formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
        });
        html5QrCode.start({ deviceId: cameraId }, scanConfig, (decodedText) => {
          this.pushEvent("scanned", decodedText);
        });

        this.handleEvent("change_camera", async ({ id }) => {
          await html5QrCode.stop();
          html5QrCode.start(id, scanConfig, (decodedText, _) => {
            this.pushEvent("scanned", decodedText);
          });
        });
      },
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
