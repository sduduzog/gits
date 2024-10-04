import { TurnstileHook } from "phoenix_turnstile";
import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode";
import {
	computePosition,
	flip,
	shift,
	autoUpdate,
	offset,
} from "@floating-ui/dom";

const scanSize = 260;
const scanConfig = {
	qrbox: { width: scanSize, height: scanSize },
};

const QrScanner = {
	initialiseCamera() {
		const { id, label } = this.currentCamera;
		const span = this.el.querySelector("span#camera-label");
		span.innerText = label;
		this.html5QrCode = new Html5Qrcode("scanner", {
			formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
		});
		this.html5QrCode.start(id, scanConfig, async (decodedText) => {
			await this.html5QrCode.stop();
			this.pushEvent("scanned", decodedText);
		});
	},
	async mounted() {
		const rotateCamera = this.el.querySelector("button#rotate-camera");
		rotateCamera.addEventListener("click", async () => {
			const index = this.cameras.findIndex(
				(camera) => camera.id === this.currentCamera.id,
			);
			const nextIndex = index === this.cameras.length - 1 ? 0 : index + 1;
			this.currentCamera = this.cameras[nextIndex];
			window.localStorage.setItem("camera_id", this.currentCamera.id);
			await this.html5QrCode.stop();
			this.initialiseCamera();
		});
		this.cameras = await Html5Qrcode.getCameras();
		const id = window.localStorage.getItem("camera_id");
		const previousCamera = this.cameras.find((camera) => camera.id === id);
		const [camera] = this.cameras;
		this.currentCamera = previousCamera || camera;
		this.initialiseCamera();
	},
};

const CopyLinkButton = {
	mounted() {
		const textElement = this.el.querySelector("span:not(.hero-link-mini)");
		this.el.addEventListener("click", async () => {
			await navigator.clipboard.writeText(this.el.dataset.uri);
			textElement.innerText = "Link copied";
			setTimeout(() => {
				textElement.innerText = "Copy link";
			}, 1500);
		});
	},
};

const Dropdown = {
	mounted() {
		const dropdownButton = this.el.querySelector("button[data-dropdown]");
		const dropdownOptions = this.el.querySelector("div[data-dropdown]");

		this.cleanup = autoUpdate(dropdownButton, dropdownOptions, () => {
			computePosition(this.el, dropdownOptions, {
				placement: "bottom-end",
				middleware: [flip(), offset(10), shift({ padding: 5 })],
			}).then(({ x, y }) => {
				Object.assign(dropdownOptions.style, {
					left: `${x}px`,
					top: `${y}px`,
				});
			});
		});
	},
	destroyed() {
		this.cleanup?.();
	},
};

export const Hooks = {
	QrScanner,
	Turnstile: TurnstileHook,
	CopyLinkButton,
	Dropdown,
};
