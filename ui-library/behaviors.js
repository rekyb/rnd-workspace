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

  /* ---- RadioGroup ----------------------------------------------------
     Contract: .radio-group > .radio-field > .radio-item[data-state],
     .radio-indicator, .radio-label. One checked item per group, roving
     tabindex, arrow keys move and select. Ported 2026-07-29. */
  function initRadioGroup(root) {
    all(root, '.radio-group').forEach(function (group) {
      var items = all(group, '.radio-item');
      if (!items.length) { return; }

      function select(item, focus) {
        items.forEach(function (i) {
          var on = i === item;
          i.setAttribute('data-state', on ? 'checked' : 'unchecked');
          i.setAttribute('aria-checked', on ? 'true' : 'false');
          i.tabIndex = on ? 0 : -1;
        });
        if (focus) { item.focus(); }
        group.dispatchEvent(new CustomEvent('rndui:change', {
          bubbles: true,
          detail: { value: item.getAttribute('data-value'), item: item }
        }));
      }

      if (!group.hasAttribute('role')) { group.setAttribute('role', 'radiogroup'); }

      items.forEach(function (item, idx) {
        if (!item.hasAttribute('role')) { item.setAttribute('role', 'radio'); }
        if (!item.hasAttribute('data-state')) {
          item.setAttribute('data-state', 'unchecked');
          item.setAttribute('aria-checked', 'false');
        }
        item.tabIndex = item.getAttribute('data-state') === 'checked' ? 0 : -1;

        item.addEventListener('click', function () { select(item, false); });
        item.addEventListener('keydown', function (e) {
          var k = e.key;
          if (k === ' ' || k === 'Enter') { e.preventDefault(); select(item, true); return; }
          var step = (k === 'ArrowDown' || k === 'ArrowRight') ? 1
            : (k === 'ArrowUp' || k === 'ArrowLeft') ? -1 : 0;
          if (!step) { return; }
          e.preventDefault();
          select(items[(idx + step + items.length) % items.length], true);
        });
      });

      var anyChecked = items.filter(function (i) {
        return i.getAttribute('data-state') === 'checked';
      }).length > 0;
      if (!anyChecked) { items[0].tabIndex = 0; }
    });
  }

  /* ---- Checkbox ------------------------------------------------------
     Contract: .checkbox-field > .checkbox-root[data-state],
     .checkbox-indicator, .checkbox-label. Ported 2026-07-29. */
  function initCheckbox(root) {
    all(root, '.checkbox-root').forEach(function (box) {
      if (!box.hasAttribute('role')) { box.setAttribute('role', 'checkbox'); }
      if (!box.hasAttribute('data-state')) { box.setAttribute('data-state', 'unchecked'); }
      if (!box.hasAttribute('tabindex')) { box.tabIndex = 0; }
      box.setAttribute('aria-checked', box.getAttribute('data-state') === 'checked' ? 'true' : 'false');

      function toggle() {
        var on = box.getAttribute('data-state') !== 'checked';
        box.setAttribute('data-state', on ? 'checked' : 'unchecked');
        box.setAttribute('aria-checked', on ? 'true' : 'false');
        box.dispatchEvent(new CustomEvent('rndui:change', {
          bubbles: true, detail: { checked: on }
        }));
      }
      box.addEventListener('click', toggle);
      box.addEventListener('keydown', function (e) {
        if (e.key === ' ' || e.key === 'Enter') { e.preventDefault(); toggle(); }
      });
    });
  }

  /* ---- PasswordInput -------------------------------------------------
     Contract: .input plus a visibility toggle. The toggle is any element
     carrying data-password-toggle="<input id>". Ported 2026-07-29. */
  function initPasswordInput(root) {
    all(root, '[data-password-toggle]').forEach(function (btn) {
      var input = document.getElementById(btn.getAttribute('data-password-toggle'));
      if (!input) { return; }
      btn.setAttribute('aria-controls', input.id);
      function sync() {
        var shown = input.type === 'text';
        btn.setAttribute('aria-pressed', shown ? 'true' : 'false');
        btn.textContent = shown ? 'Hide' : 'Show';
      }
      sync();
      btn.addEventListener('click', function () {
        input.type = input.type === 'password' ? 'text' : 'password';
        sync();
        input.focus();
      });
    });
  }

  /* ---- Select --------------------------------------------------------
     Contract: .select-trigger, .select-icon, .select-content,
     .select-viewport, .select-item[data-state|data-highlighted|data-disabled],
     .select-check. Listbox semantics, type-ahead, Escape closes.
     Ported 2026-07-29. */
  function initSelect(root) {
    all(root, '.select-trigger').forEach(function (trigger) {
      var contentId = trigger.getAttribute('aria-controls');
      var content = contentId ? document.getElementById(contentId) : null;
      if (!content) { return; }
      var items = all(content, '.select-item');
      var typed = '';
      var typedAt = 0;

      function highlight(item) {
        items.forEach(function (i) {
          if (i === item) { i.setAttribute('data-highlighted', ''); i.focus(); }
          else { i.removeAttribute('data-highlighted'); }
        });
      }
      function open(isOpen) {
        content.setAttribute('data-state', isOpen ? 'open' : 'closed');
        content.hidden = !isOpen;
        trigger.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
        if (isOpen && items.length) {
          var checked = items.filter(function (i) {
            return i.getAttribute('data-state') === 'checked';
          })[0];
          highlight(checked || items[0]);
        }
      }
      function choose(item) {
        if (item.hasAttribute('data-disabled')) { return; }
        items.forEach(function (i) {
          i.setAttribute('data-state', i === item ? 'checked' : 'unchecked');
        });
        var label = trigger.querySelector('[data-select-value]') || trigger;
        label.textContent = item.textContent.trim();
        trigger.setAttribute('data-value', item.getAttribute('data-value') || '');
        open(false);
        trigger.focus();
        trigger.dispatchEvent(new CustomEvent('rndui:change', {
          bubbles: true,
          detail: { value: item.getAttribute('data-value'), label: item.textContent.trim() }
        }));
      }

      if (!trigger.hasAttribute('role')) { trigger.setAttribute('role', 'combobox'); }
      trigger.setAttribute('aria-haspopup', 'listbox');
      if (!content.hasAttribute('role')) { content.setAttribute('role', 'listbox'); }
      open(false);

      trigger.addEventListener('click', function () {
        open(content.getAttribute('data-state') !== 'open');
      });
      trigger.addEventListener('keydown', function (e) {
        if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          open(true);
        }
      });

      items.forEach(function (item, idx) {
        if (!item.hasAttribute('role')) { item.setAttribute('role', 'option'); }
        item.tabIndex = -1;
        item.addEventListener('click', function () { choose(item); });
        item.addEventListener('keydown', function (e) {
          var k = e.key;
          if (k === 'Escape') { e.preventDefault(); open(false); trigger.focus(); return; }
          if (k === 'Enter' || k === ' ') { e.preventDefault(); choose(item); return; }
          var step = k === 'ArrowDown' ? 1 : k === 'ArrowUp' ? -1 : 0;
          if (step) {
            e.preventDefault();
            highlight(items[(idx + step + items.length) % items.length]);
            return;
          }
          if (k.length === 1 && /\S/.test(k)) {
            var now = Date.now();
            typed = (now - typedAt < 800) ? typed + k.toLowerCase() : k.toLowerCase();
            typedAt = now;
            var hit = items.filter(function (i) {
              return i.textContent.trim().toLowerCase().indexOf(typed) === 0;
            })[0];
            if (hit) { highlight(hit); }
          }
        });
      });
    });
  }

  function init(root) {
    var scope = root || document;
    initTabs(scope);
    initAccordion(scope);
    initDialog(scope);
    initToast(scope);
    initRadioGroup(scope);
    initCheckbox(scope);
    initPasswordInput(scope);
    initSelect(scope);
  }

  global.RndUI = {
    init: init,
    initTabs: initTabs,
    initAccordion: initAccordion,
    initDialog: initDialog,
    initToast: initToast,
    initRadioGroup: initRadioGroup,
    initCheckbox: initCheckbox,
    initPasswordInput: initPasswordInput,
    initSelect: initSelect
  };
})(this);
