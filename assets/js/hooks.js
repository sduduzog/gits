import Sortable from "sortablejs";
function turnstileCallbackEvent(self, name, eventName) {
  return (payload) => {
    const events = self.el.dataset.events || "";

    if (events.split(",").indexOf(name) > -1) {
      self.pushEventTo(self.el, `turnstile:${eventName || name}`, payload);
    }
  };
}

export const TurnstileHook = {
  mounted() {
    turnstile.render(this.el, {
      callback: turnstileCallbackEvent(this, "success"),
      "error-callback": turnstileCallbackEvent(this, "error"),
      "expired-callback": turnstileCallbackEvent(this, "expired"),
      "before-interactive-callback": turnstileCallbackEvent(
        this,
        "beforeInteractive",
        "before-interactive",
      ),
      "after-interactive-callback": turnstileCallbackEvent(
        this,
        "afterInteractive",
        "after-interactive",
      ),
      "unsupported-callback": turnstileCallbackEvent(this, "unsupported"),
      "timeout-callback": turnstileCallbackEvent(this, "timeout"),
    });

    this.handleEvent("turnstile:refresh", (event) => {
      if (!event.id || event.id === this.el.id) {
        turnstile.reset(this.el);
      }
    });

    this.handleEvent("turnstile:remove", (event) => {
      if (!event.id || event.id === this.el.id) {
        turnstile.remove(this.el);
      }
    });
  },
};

const QrScannerCameraList = {
  async mounted() {
    const cameras = await window.Html5Qrcode.getCameras();
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
    console.log(this.liveSocket);
    const cameraId = this.el.dataset.camera;
    const html5QrCode = new window.Html5Qrcode(this.el.id, {
      formatsToSupport: [window.Html5QrcodeSupportedFormats.QR_CODE],
    });

    html5QrCode.start(
      cameraId,
      { fps: 2, aspectRatio: 1 },
      async (decodedText) => {
        this.pushEvent("scanned", { text: decodedText });
        this.liveSocket.execJS(this.el, this.el.getAttribute("data-callback"));
      },
    );
  },
};

const HostDraggableTicketContainer = {
  mounted() {
    function onSortHandler(data) {
      this.pushEventTo("#tickets", "sort_ticket", data);
    }

    const sortHandler = onSortHandler.bind(this);

    Sortable.create(this.el, {
      handle: ".handle",
      onSort: (evt) => {
        sortHandler({
          id: evt.item.dataset.id,
          new_index: evt.newIndex,
          old_index: evt.oldIndex,
        });
      },
    });
  },
};

export const Hooks = {
  QrScanner,
  QrScannerCameraList,
  Turnstile: TurnstileHook,
  HostDraggableTicketContainer,
};
