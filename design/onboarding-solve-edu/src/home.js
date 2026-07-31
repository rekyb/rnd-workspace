/* Learning Home — the second half of the journey.
 *
 * Reads the handoff written by main.js at finalization. Three rules, all from
 * design/onboarding-solve-edu/PRD.md Cycle 2:
 *
 *  1. No progress value is a literal. Every number comes from the handoff or is
 *     computed from it. The screen this replaces hard-coded a 1-day streak, a
 *     150-point total and a 40% bar for a learner who had done nothing.
 *
 *  2. The primary action comes from the stored initialCourseId. Nothing here
 *     consults an activity history, a recency list, or a popularity ordering,
 *     because at first run they have nothing to rank.
 *
 *  3. Every zero states, in the same slot, what would change it.
 */
(function () {
  'use strict';

  var SKELETON_DELAY_MS = 400; // do not show a skeleton for a wait shorter than this
  var SKELETON_MIN_MS = 500;   // once shown, hold it this long so it cannot flash
  var FAKE_LATENCY_MS = 1100;  // stands in for the finalization call

  var state = null;
  var skeletonShownAt = null;

  function $(id) { return document.getElementById(id); }
  function setText(id, v) { var el = $(id); if (el) el.textContent = v; }
  /* Visibility is a class, not an inline style. An inline display value cannot
     be reached by a media query, which is what stopped the narrow layout from
     being expressible at all before Cycle 3. */
  function show(id, on) { var el = $(id); if (el) el.classList.toggle('is-hidden', !on); }

  /* The out-of-scope note lives in every view, and the one that matters is the
     one in the card currently on screen. Previously a single node sat inside
     the Learning Home, so on the skill screen and in the error state every
     destination wrote its message into a hidden element and said nothing. */
  function noteEl() { return document.querySelector('.home-card.active .home-nav-note'); }
  function say(message) {
    var n = noteEl();
    if (!n) return;
    /* Unhide before writing: a mutation inside a display:none live region is
       unreliably announced. */
    n.classList.remove('is-hidden');
    n.textContent = message;
  }
  function hideNote() {
    var n = noteEl();
    if (n) n.classList.add('is-hidden');
  }

  function load() {
    var raw = null;
    try { raw = sessionStorage.getItem('se_handoff'); } catch (e) {}
    if (raw) {
      /* A malformed payload is a finalization failure, not a crash. Parsing it
         unguarded threw inside boot() and left the learner on the skeleton for
         ever, which is the permanent-skeleton case Slice 12 forbids. */
      try { return JSON.parse(raw); } catch (e) { return null; }
    }
    if (!raw) {
      /* Opened directly, without walking the funnel. Say so rather than
         inventing a learner. */
      return {
        displayName: 'Learner',
        entryPath: 'organic',
        goalId: null,
        initialCourseId: null,
        courseTitle: null,
        skillTotal: null,
        firstSkillTitle: null,
        firstSkillMinutes: null,
        programName: null,
        skillsDone: 0,
        tasksDone: 0,
        firstActionAt: null,
        standalone: true,
        programTasks: null,
        taskTotal: null
      };
    }
  }

  /* The recoverable failure state. The shell stays, the skeleton stops, and the
     learner is told the cause and offered a retry (Slice 12, error state). */
  function renderError(message) {
    show('home_skeleton', false);
    if (message) setText('home_error_body', message);
    show('home_error', true);
    setText('loading_greeting', 'Something went wrong');
    setText('loading_sub', '');
    showScreen('home_loading');
  }

  function save() {
    try { sessionStorage.setItem('se_handoff', JSON.stringify(state)); } catch (e) {}
  }

  function showScreen(id) {
    ['home_loading', 'learning_home', 'skill_screen'].forEach(function (s) {
      var el = $(s);
      if (el) el.classList.toggle('active', s === id);
    });
    /* A transient note belongs to the moment, not to the session. Leaving one
       up across a view change made "Evidence is out of scope" follow the
       learner home. */
    var notes = document.querySelectorAll('.home-nav-note');
    Array.prototype.forEach.call(notes, function (n) { n.classList.add('is-hidden'); });
    window.scrollTo(0, 0);
  }

  /* ---- the countable condition, in the slot ---- */
  function conditionFor(done, total, one, many) {
    if (!total) return '';
    if (done === 0) return 'Finish 1 ' + one + ' to see progress here';
    var left = total - done;
    if (left === 0) return 'All ' + total + ' ' + many + ' complete';
    return left + ' ' + (left === 1 ? one : many) + ' to go';
  }

  /* ---- the primary action's label ----
     Names one specific, time-bounded item rather than offering a course
     (PRD Slice 13, from layout F6). An absent duration and a null duration are
     treated identically and the cost is omitted: a replayed handoff written
     before the field existed has no key at all, and a client that
     distinguished the two would show a cost line to some learners and not
     others on the same code path. A guessed estimate is the fabrication class
     this build exists to remove. */
  function actionLabel(first, item, minutes) {
    var verb = first ? 'Start' : 'Continue';
    if (!item) return verb + ' ' + state.courseTitle;
    var hasCost = typeof minutes === 'number' && minutes > 0;
    return verb + ': ' + item + (hasCost ? ' · ' + minutes + ' min' : '');
  }

  function renderHome() {
    var first = state.firstActionAt === null;
    var isProgram = state.entryPath === 'program';
    var mapped = !!state.initialCourseId;

    setText('home_greeting', first
      ? 'Ready when you are, ' + state.displayName
      : 'Good to see you again, ' + state.displayName);

    setText('home_sub', state.standalone
      ? 'Opened directly, so this is a sample learner. Walk the onboarding to see your own.'
      : (first
        ? 'You have not started anything yet. Here is where to begin.'
        : 'Picking up where you stopped.'));

    /* Up Next, or the unmapped empty state. Never both, never a substitute. */
    show('home_up_next', mapped);
    show('home_unmapped', !mapped);
    /* Gated on the same boolean as the panels above, so the mapped action and
       the unmapped recovery can never both be filled controls on one screen. */
    show('start-lesson-btn', mapped);

    if (mapped) {
      var done = state.skillsDone;
      var total = state.skillTotal;
      setText('home_course_title', state.courseTitle);
      setText('home_course_unit', 'First unit of your course');
      setText('home_course_count', done + ' of ' + total + ' skills');
      setText('home_course_condition', conditionFor(done, total, 'skill', 'skills'));
      $('home_course_fill').style.width = Math.round((done / total) * 100) + '%';
      setText('start-lesson-btn',
        actionLabel(first, state.firstSkillTitle, state.firstSkillMinutes));
    }

    /* Program tasks */
    var tasks = $('home_program_tasks');
    show('home_program_tasks', isProgram);

    /* The dominant object depends on the entry path (PRD 11.1). A program
       learner's assigned work outranks a goal-derived suggestion, so the task
       panel moves above Up Next; an organic learner has no assigned work and
       Up Next stays first. Moving the node keeps one markup order that the
       data reorders, rather than two branches that can drift apart. */
    var main = tasks.parentNode;
    if (isProgram) {
      main.insertBefore(tasks, $('home_up_next'));
    } else {
      main.insertBefore($('home_up_next'), tasks);
    }

    if (isProgram) {
      /* The task list and its denominator arrive on the handoff, written at
         finalization from the enrolment. They were previously a constant in
         this file, which made the denominator a client-side literal and
         pre-checked the first row — structurally the same defect as the
         fabricated progress Cycle 2 removed, however defensible the content. */
      var taskRows = state.programTasks || [];
      var tDone = taskRows.filter(function (t, i) { return t.done || i <= state.tasksDone - 1; }).length;
      var tTotal = state.taskTotal || taskRows.length;
      setText('home_program_name', state.programName);
      setText('home_program_count', tDone + ' of ' + tTotal + ' tasks');
      setText('home_program_condition', conditionFor(tDone, tTotal, 'task', 'tasks'));

      var list = $('home_task_list');
      list.textContent = '';
      taskRows.forEach(function (task, i) {
        var complete = task.done || i <= state.tasksDone - 1;
        var row = document.createElement('label');
        row.className = 'home-task-row';
        var box = document.createElement('input');
        box.type = 'checkbox';
        box.disabled = true;
        box.checked = complete;
        box.className = 'home-task-box';
        row.appendChild(box);
        row.appendChild(document.createTextNode(' ' + task.title));
        list.appendChild(row);
      });
    }

    /* Arriving home means Home is where the learner is. Without this the top
       bar kept marking whichever family they last opened, which is the same
       lie the Home handler used to tell from the other direction. */
    markLocation(null, null);
    showScreen('learning_home');
  }

  function openSkill() {
    setText('skill_course', state.courseTitle + ' · skill ' + (state.skillsDone + 1) + ' of ' + state.skillTotal);
    /* The destination names the same item the action named. Only the first
       skill has a title in the handoff, so later ones fall back to their
       position rather than borrowing a name that is not theirs. */
    setText('skill_title', (state.skillsDone === 0 && state.firstSkillTitle)
      ? state.firstSkillTitle
      : 'Skill ' + (state.skillsDone + 1));
    /* A lesson lives under Learn, so that is the family the bar marks while the
       learner is in one. Without this the bar kept whichever family they had
       opened on the way out. */
    markLocation('learn', null);
    showScreen('skill_screen');
  }

  function completeSkill() {
    if (state.skillsDone < state.skillTotal) state.skillsDone += 1;
    var tTotal = state.taskTotal || (state.programTasks ? state.programTasks.length : 0);
    if (state.entryPath === 'program' && state.tasksDone < tTotal) {
      state.tasksDone += 1;
    }
    /* This is what stops every learner being "first run" forever, and what makes
       the returning state reachable in the prototype. */
    state.firstActionAt = new Date().toISOString();
    save();
    renderXp();
    renderHome();
  }

  /* ---- the labelled wait, with both numbers actually applied ----
     Slice 12's two-number rule. The skeleton is revealed only if the wait
     outlasts SKELETON_DELAY_MS, and once revealed it is held SKELETON_MIN_MS
     from the moment it appeared. The earlier version shipped the skeleton
     visible and computed its reveal time in advance, so the delay suppressed
     nothing and the hold always resolved to zero: the constants were declared
     and neither was in force. */
  function finalize(latencyMs, shouldFail) {
    var revealTimer = setTimeout(function () {
      skeletonShownAt = Date.now();
      show('home_skeleton', true);
    }, SKELETON_DELAY_MS);

    setTimeout(function () {
      clearTimeout(revealTimer);
      var hold = skeletonShownAt === null
        ? 0
        : Math.max(0, skeletonShownAt + SKELETON_MIN_MS - Date.now());
      setTimeout(function () {
        if (shouldFail) {
          renderError('The connection dropped before your profile was saved. Nothing was lost.');
          return;
        }
        show('home_skeleton', false);
        renderHome();
      }, hold);
    }, latencyMs);
  }

  function boot() {
    state = load();

    /* Prototype controls, read from the query string: `?fail=1` exercises the
       recoverable failure state and `?latency=200` a wait short enough that the
       skeleton must never appear. Both are real code paths rather than debug
       switches that bypass the render. */
    var params = new URLSearchParams(window.location.search);
    var shouldFail = params.get('fail') === '1' || state === null;
    var latency = parseInt(params.get('latency'), 10);
    if (isNaN(latency)) latency = FAKE_LATENCY_MS;

    if (state === null) {
      /* A payload that will not parse is a failed finalization, not a crash. */
      renderError('Your setup data could not be read. Nothing was lost, and you can start again.');
      wire();
      return;
    }

    setText('loading_greeting', 'Setting things up, ' + state.displayName);
    wire();
    renderXp();

    /* Restore the learner's own choices before anything paints, so the theme
       does not flash from light to dark on a second visit. */
    var savedTheme = null, savedLang = null;
    try { savedTheme = localStorage.getItem('se_theme'); savedLang = localStorage.getItem('se_lang'); } catch (e) {}
    if (savedTheme === 'dark') applyTheme(true);
    if (savedLang === 'id') { applyLang('id'); hideNote(); }

    /* A learner returning to an account that already has history skips the
       labelled wait: there is nothing to prepare. */
    if (state.firstActionAt !== null && !shouldFail) { renderHome(); return; }

    finalize(latency, shouldFail);
  }

  /* ---- family panels ----
     Four top-level families stand in for eleven production destinations. A top
     bar cannot keep all eleven visible the way the old sidebar could, so eight
     sit one level down — and a panel shows its whole family at once rather than
     nesting further, which is the difference between one level of depth and the
     push-depth-down arm the cited study rejects. */
  function closeAllPanels() {
    var panels = document.querySelectorAll('.home-nav-panel');
    Array.prototype.forEach.call(panels, function (p) { p.classList.add('is-hidden'); });
    var triggers = document.querySelectorAll('[data-family]');
    Array.prototype.forEach.call(triggers, function (t) { t.setAttribute('aria-expanded', 'false'); });
  }

  function openFamily(trigger) {
    var id = trigger.getAttribute('aria-controls');
    var panel = document.getElementById(id);
    var wasOpen = panel && !panel.classList.contains('is-hidden');
    closeAllPanels();
    if (panel && !wasOpen) {
      panel.classList.remove('is-hidden');
      trigger.setAttribute('aria-expanded', 'true');
    }
  }

  /* ---- XP ----
     Derived from durable learner data, never declared. A first-run learner has
     completed nothing, so this reads 0 — the same rule as every other counter
     on this surface. A literal here would be the 150-point pill the 2026-07-28
     benchmark was commissioned over and PRD 5.3 blocks release for. */
  var XP_PER_SKILL = 20;

  function renderXp() {
    var xp = (state && typeof state.skillsDone === 'number') ? state.skillsDone * XP_PER_SKILL : 0;
    var nodes = document.querySelectorAll('[id^="home_xp_value"]');
    Array.prototype.forEach.call(nodes, function (n) { n.textContent = String(xp); });
  }

  /* ---- theme ----
     A tonal variant, applied by re-pointing surface and text tokens on the root
     element. aria-pressed carries the state, and the label says what the
     control will do rather than what mode is current. */
  function applyTheme(dark) {
    var root = document.documentElement;
    if (dark) { root.setAttribute('data-theme', 'dark'); }
    else { root.removeAttribute('data-theme'); }
    try { localStorage.setItem('se_theme', dark ? 'dark' : 'light'); } catch (e) {}
    var btns = document.querySelectorAll('[id^="theme_btn"]');
    Array.prototype.forEach.call(btns, function (b) {
      b.setAttribute('aria-pressed', dark ? 'true' : 'false');
      b.setAttribute('aria-label', dark ? 'Switch to light mode' : 'Switch to dark mode');
      var icon = b.querySelector('.material-symbols-rounded');
      if (icon) icon.textContent = dark ? 'light_mode' : 'dark_mode';
    });
  }

  /* ---- language ----
     The prototype switches the indicator and records the choice; the string
     catalogue itself is out of scope, so the control says so rather than
     pretending the interface translated. */
  function applyLang(code) {
    var name = code === 'id' ? 'Bahasa Indonesia' : 'English';
    try { localStorage.setItem('se_lang', code); } catch (e) {}
    var codes = document.querySelectorAll('[id^="lang_code"]');
    Array.prototype.forEach.call(codes, function (n) { n.textContent = code.toUpperCase(); });
    var btns = document.querySelectorAll('[id^="lang_btn"]');
    Array.prototype.forEach.call(btns, function (b) {
      b.setAttribute('aria-label', 'Change language, current language ' + name);
    });
    /* The document's lang attribute is deliberately NOT changed. Declaring
       lang="id" over English copy is a WCAG 3.1.1 falsehood: a screen reader
       would voice English strings with Indonesian phonemes. The preference is
       recorded; the interface has not translated, and the message says so. */
    say(name + ' selected. Interface strings are out of scope for this prototype.');
  }

  /* ---- where the learner is ----
     Marking does two jobs, which is the study's reading of Codecademy: it says
     where the learner is, and which family they are navigating within. A
     learner on Practice sees Learn marked in the top bar and Practice marked
     inside its panel. Without the first job, a top-level row of families tells
     the learner nothing once they are inside one. */
  function markLocation(familyName, childName) {
    var items = document.querySelectorAll('.home-nav-item');
    Array.prototype.forEach.call(items, function (b) {
      var isCurrent = familyName
        ? b.getAttribute('data-family') === familyName
        : b.getAttribute('data-stub') === 'Home';
      b.classList.toggle('active', isCurrent);
      if (isCurrent) { b.setAttribute('aria-current', 'page'); }
      else { b.removeAttribute('aria-current'); }
    });
    var children = document.querySelectorAll('.home-nav-child');
    Array.prototype.forEach.call(children, function (b) {
      var isCurrent = !!childName && b.getAttribute('data-stub') === childName;
      b.classList.toggle('active', isCurrent);
      if (isCurrent) { b.setAttribute('aria-current', 'page'); }
      else { b.removeAttribute('aria-current'); }
    });
  }

  /* Which family a destination belongs to. Derived from the markup rather than
     duplicated as a table, so the two cannot drift apart. */
  function familyOf(stub) {
    var child = document.querySelector('.home-nav-child[data-stub="' + stub + '"]');
    if (!child) return null;
    var panel = child.closest('.home-nav-panel');
    if (!panel) return null;
    var trigger = panel.parentElement.querySelector('.home-nav-item[data-family]');
    return trigger ? trigger.getAttribute('data-family') : null;
  }

  function wire() {
    $('start-lesson-btn').addEventListener('click', openSkill);
    $('skill_done_btn').addEventListener('click', completeSkill);
    $('skill_back_btn').addEventListener('click', renderHome);
    $('unmapped_choose_btn').addEventListener('click', function () {
      window.location.href = 'onboarding.html';
    });
    $('home_retry_btn').addEventListener('click', function () {
      window.location.href = window.location.pathname;
    });

    /* Every [data-family] control, not just the ones styled as nav items. The
       language switch is a .home-icon-btn, so a .home-nav-item selector left it
       unbound: its panel never opened and the two language choices inside it
       were unreachable. Five panels per view, not four. */
    var famTriggers = document.querySelectorAll('[data-family]');
    Array.prototype.forEach.call(famTriggers, function (t) {
      t.addEventListener('click', function (e) { e.stopPropagation(); openFamily(t); });
    });
    /* A click anywhere else, or Escape, closes an open panel. Without both, the
       panel is a trap: it opens on click and has no dismissal. */
    document.addEventListener('click', closeAllPanels);
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') closeAllPanels();
    });

    var themeBtns = document.querySelectorAll('[id^="theme_btn"]');
    Array.prototype.forEach.call(themeBtns, function (b) {
      b.addEventListener('click', function (e) {
        e.stopPropagation();
        applyTheme(document.documentElement.getAttribute('data-theme') !== 'dark');
      });
    });

    var langChoices = document.querySelectorAll('.home-nav-child[data-lang]');
    Array.prototype.forEach.call(langChoices, function (b) {
      b.addEventListener('click', function () { applyLang(b.getAttribute('data-lang')); });
    });

    /* Every destination is focusable, so every destination answers — the panel
       members and the profile menu too, not only the top row. A control that
       takes focus and does nothing is a dead end; these say why they do nothing
       instead of swallowing the click. */
    var stubs = document.querySelectorAll('[data-stub]');
    Array.prototype.forEach.call(stubs, function (b) {
      b.addEventListener('click', function () {
        var name = b.getAttribute('data-stub');
        /* Home navigates. Marking it current without changing the view made the
           one signal this whole change exists to add tell a lie: on the skill
           screen it claimed the learner was on Home while the skill screen was
           still rendered. */
        if (name === 'Home') { hideNote(); renderHome(); return; }
        /* The family is marked even though the destination is a stub: marking
           is what the top bar owes the learner, and it is demonstrable without
           building the ten pages behind it. */
        markLocation(familyOf(name), name);
        say(name + ' is out of scope for this prototype.');
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
