import { TurnstileHook } from "phoenix_turnstile";
import { Html5Qrcode, Html5QrcodeSupportedFormats } from "html5-qrcode";
import {
  computePosition,
  flip,
  shift,
  autoUpdate,
  offset,
} from "@floating-ui/dom";

import Quill from "quill";

const QuillEditor = {
  _setup() {
    const onTextChange = (_, __, source) => {
      if (source === "user") {
        const delta = this.quill.getContents();
        hiddenField.value = JSON.stringify(delta);
        hiddenField.dispatchEvent(new Event("input", { bubbles: true }));
      }
    };

    this.quill?.off("text-change", onTextChange);

    const ops = JSON.parse(this.el.dataset.contents || '{"ops": []}');

    const editor = document.createElement("div");
    editor.style.height = "calc(100% - 48px)";

    const hiddenField = document.createElement("input");
    hiddenField.type = "hidden";
    hiddenField.name = this.el.dataset.name;
    hiddenField.value = this.el.dataset.contents;

    this.el.appendChild(editor);
    this.el.appendChild(hiddenField);

    const quill = new Quill(editor, {
      modules: {
        toolbar: [
          [{ header: [1, 2, 3, false] }],
          ["bold", "italic"],
          ["link"],
          [{ list: "bullet" }],
          ["bold"],
          ["link"],
        ],
      },
      theme: "snow",
    });

    quill.on("text-change", onTextChange);
    this.quill = quill;

    this.quill.setContents(ops);
  },
  mounted() {
    this._setup();
  },
  updated() {
    this._setup();
  },
};

const QrScannerCameraList = {
  async mounted() {
    const cameras = await Html5Qrcode.getCameras();
    for (const camera of cameras) {
      const element = document.createElement("span");
      element.classList.add(
        "text-sm",
        "p-2",
        "hover:bg-zinc-50",
        "rounded-lg",
        "font-semibold",
      );

      element.id = camera.id;
      element.setAttribute("phx-value-id", camera.id);
      element.innerText = camera.label;
      element.addEventListener("click", () => {
        this.pushEvent("camera_choice", camera);
      });
      this.el.appendChild(element);
    }
  },
};

const QrScanner = {
  async mounted() {
    const cameraId = this.el.dataset.camera;
    const html5QrCode = new Html5Qrcode(this.el.id, {
      formatsToSupport: [Html5QrcodeSupportedFormats.QR_CODE],
    });

    html5QrCode.start(cameraId, { aspectRatio: 1 }, async (decodedText) => {
      console.log({ decodedText });
    });
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
  QuillEditor,
  QrScanner,
  QrScannerCameraList,
  Turnstile: TurnstileHook,
  CopyLinkButton,
  Dropdown,
};
