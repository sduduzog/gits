import { TurnstileHook } from "phoenix_turnstile";
import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode";

const scanSize = 260
let html5QrCode;
const scanConfig = {
  qrbox: { width: scanSize, height: scanSize },
};


const QrScanner = {
  initialiseCamera() {
    const {id} = this.currentCamera
    this.html5QrCode = new Html5Qrcode("scanner", {
      formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
    });
    this.html5QrCode.start(id, scanConfig, async (decodedText) => {
      await html5QrCode.stop()
      this.pushEvent("scanned", decodedText);
    });
  },
  async mounted() {
    const rotateCamera = this.el.querySelector("button#rotate-camera")
    rotateCamera.addEventListener("click", async (e) => {
      const index = this.cameras.findIndex(camera => camera.id === this.currentCamera.id)
      const nextIndex = index === (this.cameras.length - 1) ? 0 : index + 1
      this.currentCamera = this.cameras[nextIndex]
      await this.html5QrCode.stop()
      this.initialiseCamera()
    })
    console.log(rotateCamera)
    this.cameras = await Html5Qrcode.getCameras()
    const [camera] = this.cameras;
    this.currentCamera = camera
    this.initialiseCamera()
  },
}


export const Hooks = {
  QrScanner,
  Turnstile: TurnstileHook,
}

