// Acme white-label — plugin slot-only (tab.hidden). Hace lo que el customCSS del
// tema no puede: marca del navegador (document.title) y favicon. Todo el
// rebranding visual del panel vive en seed/dashboard-themes/acme.yaml.
(function () {
  "use strict";

  var BRAND = "Acme Maquinaria Especial \u2014 Panel";
  var FAVICON =
    "data:image/svg+xml," +
    encodeURIComponent(
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 32 32'>" +
        "<rect width='32' height='32' rx='6' fill='#1a1f26'/>" +
        "<path d='M6 25 L16 7 L26 25 Z' fill='none' stroke='#f59e0b' stroke-width='3' stroke-linejoin='round'/>" +
        "<path d='M11 25 L21 25' stroke='#2563eb' stroke-width='3' stroke-linecap='round'/>" +
        "</svg>"
    );

  function setFavicon() {
    var links = document.querySelectorAll('link[rel~="icon"]');
    if (!links.length) {
      var link = document.createElement("link");
      link.rel = "icon";
      document.head.appendChild(link);
      links = [link];
    }
    links.forEach(function (link) {
      link.setAttribute("type", "image/svg+xml");
      link.setAttribute("href", FAVICON);
    });
  }

  // La SPA reescribe <title> por ruta ("Sessions - Hermes ..."). Reafirmamos la
  // marca Acme y la mantenemos ante cambios de ruta. indexOf evita bucle: tras
  // fijar BRAND la siguiente mutación ya contiene "Acme" y no reescribe.
  function brandTitle() {
    if (document.title.indexOf("Acme") === -1) {
      document.title = BRAND;
    }
  }

  setFavicon();
  brandTitle();

  var titleEl = document.querySelector("title");
  if (titleEl && typeof MutationObserver !== "undefined") {
    new MutationObserver(brandTitle).observe(titleEl, { childList: true });
  }
  window.addEventListener("popstate", function () {
    setTimeout(brandTitle, 50);
  });

  if (window.__HERMES_PLUGINS__) {
    window.__HERMES_PLUGINS__.register("acme-admin", function () {
      return null;
    });
  }
})();
