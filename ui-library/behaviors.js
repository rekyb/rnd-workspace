/* Vanilla behavior for the ported ui-library/ components. The class and data-state contract
   mirrors the production React components, so markup written against components.css
   behaves the same here. Components absent from this file are listed as
   "not yet ported" in COMPONENTS.md - do not improvise a replacement. */
(function (global) {
  'use strict';

  function all(root, sel) { return Array.prototype.slice.call(root.querySelectorAll(sel)); }

  function initTabs(root) {
    all(root, '.tabs').forEach(function (group) {
      var tabs = all(group, '.tab');
      tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
          tabs.forEach(function (t) {
            t.setAttribute('data-state', t === tab ? 'active' : 'inactive');
            t.classList.toggle('on', t === tab);
            t.setAttribute('aria-selected', t === tab ? 'true' : 'false');
          });
          var panelId = tab.getAttribute('aria-controls');
          if (!panelId) return;
          var scope = group.parentNode || root;
          all(scope, '.tab-panel').forEach(function (p) {
            p.hidden = p.id !== panelId;
          });
        });
      });
    });
  }

  function initAccordion(root) {
    all(root, '.accordion-trigger').forEach(function (trigger) {
      trigger.addEventListener('click', function () {
        var item = trigger.closest('.accordion-item') || trigger.parentNode;
        var content = item.querySelector('.accordion-content');
        var isOpen = trigger.getAttribute('data-state') === 'open';
        var next = isOpen ? 'closed' : 'open';
        trigger.setAttribute('data-state', next);
        trigger.setAttribute('aria-expanded', isOpen ? 'false' : 'true');
        if (content) { content.setAttribute('data-state', next); }
      });
    });
  }

  function initDialog(root) {
    function focusables(panel) {
      return all(panel, 'a[href],button:not([disabled]),input:not([disabled]),select,textarea,[tabindex]:not([tabindex="-1"])');
    }
    function close(overlay) {
      overlay.setAttribute('data-state', 'closed');
      overlay.hidden = true;
      if (overlay.__lastFocus) { overlay.__lastFocus.focus(); }
    }
    all(root, '.dialog-overlay').forEach(function (overlay) {
      var panel = overlay.querySelector('.dialog-panel');
      all(overlay, '.dialog-x').forEach(function (x) {
        x.addEventListener('click', function () { close(overlay); });
      });
      overlay.addEventListener('click', function (e) {
        if (e.target === overlay) { close(overlay); }
      });
      overlay.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { close(overlay); return; }
        if (e.key !== 'Tab' || !panel) { return; }
        var items = focusables(panel);
        if (!items.length) { return; }
        var first = items[0], last = items[items.length - 1];
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
      });
    });
    all(root, '[data-dialog-open]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var overlay = document.getElementById(btn.getAttribute('data-dialog-open'));
        if (!overlay) { return; }
        overlay.__lastFocus = btn;
        overlay.hidden = false;
        // components.css has no [data-state] rule for .dialog-overlay - visibility is
        // driven by the `hidden` property above, not this attribute. It is still set
        // (here and on close, above) because production's Radix-based Dialog sets
        // data-state on the real component too; mirroring that contract keeps
        // prototype markup faithful to what the React component emits even though
        // this stylesheet happens not to style it. Do not remove it as dead code.
        overlay.setAttribute('data-state', 'open');
        var panel = overlay.querySelector('.dialog-panel');
        var items = panel ? focusables(panel) : [];
        if (items.length) { items[0].focus(); } else if (panel) { panel.focus(); }
      });
    });
  }

  function initToast(root) {
    // components.css animates the close via .toast-root[data-state="closed"]
    // (animation: toast-out ...) and the open via [data-state="open"]
    // (animation: toast-in ...) - see components.css ~L1668-1682. Removing the
    // node synchronously on click would skip that authored exit animation
    // entirely, so the close path below sets data-state="closed" and waits for
    // the animation to finish (via `animationend`) before detaching the node,
    // with a timeout fallback for prefers-reduced-motion or a browser that
    // never fires the event.
    var EXIT_FALLBACK_MS = 300; // > --t-fast (0.12s) with margin

    function detach(toast) {
      if (toast && toast.parentNode) { toast.parentNode.removeChild(toast); }
    }

    function closeToast(toast) {
      var done = false;
      function finish() {
        if (done) { return; }
        done = true;
        toast.removeEventListener('animationend', onAnimEnd);
        clearTimeout(fallback);
        detach(toast);
      }
      function onAnimEnd(e) {
        if (e.target === toast) { finish(); }
      }
      toast.addEventListener('animationend', onAnimEnd);
      var fallback = setTimeout(finish, EXIT_FALLBACK_MS);
      toast.setAttribute('data-state', 'closed');
    }

    all(root, '.toast-root').forEach(function (toast) {
      // Give the entrance animation a state to animate from for toasts already
      // present at init time (e.g. server-rendered / statically authored markup).
      if (!toast.getAttribute('data-state')) { toast.setAttribute('data-state', 'open'); }
    });

    all(root, '.toast-close').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var toast = btn.closest('.toast-root');
        if (toast) { closeToast(toast); }
      });
    });
  }

  function init(root) {
    var scope = root || document;
    initTabs(scope);
    initAccordion(scope);
    initDialog(scope);
    initToast(scope);
  }

  global.RndUI = {
    init: init,
    initTabs: initTabs,
    initAccordion: initAccordion,
    initDialog: initDialog,
    initToast: initToast
  };
})(this);
