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
import 'phoenix_html';
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from 'phoenix';
import { LiveSocket } from 'phoenix_live_view';
import topbar from '../vendor/topbar';

import {
  computePosition,
  flip,
  shift,
  autoUpdate,
  offset,
} from '@floating-ui/dom';

import { Hooks } from './hooks';

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content');

const Dropdown = {
  mounted() {
    const dropdownButton = this.el.querySelector('button[data-dropdown]');
    const dropdownOptions = this.el.querySelector('div[data-dropdown]');

    this.cleanup = autoUpdate(dropdownButton, dropdownOptions, () => {
      computePosition(this.el, dropdownOptions, {
        placement: 'bottom-end',
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

let liveSocket = new LiveSocket('/live', Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: {
    Dropdown: Dropdown,
    DropdownButton: {
      mounted() {
        const dropdown = this.el.querySelector('[data-dropdown]');
        this.cleanup = autoUpdate(this.el, dropdown, () => {
          computePosition(this.el, dropdown, {
            middleware: [flip(), shift({ padding: 5 })],
          }).then(({ x, y }) => {
            Object.assign(dropdown.style, {
              left: `${x}px`,
              top: `${y}px`,
            });
          });
        });
      },
      destroyed() {
        this.cleanup?.();
      },
    },
    HeaderOpacityOnScroll: {
      mounted() {
        document.addEventListener('scroll', function () {
          if (window.scrollY > 20) {
            const header = document.getElementById('homepage_header');
            header.classList.add('bg-opacity-100');
            header.classList.remove('bg-opacity-0');
          } else {
            const header = document.getElementById('homepage_header');
            header.classList.add('bg-opacity-0');
            header.classList.remove('bg-opacity-100');
          }
        });
      },
    },
    ...Hooks,
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#29d' }, shadowColor: 'rgba(0, 0, 0, .3)' });
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300));
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
