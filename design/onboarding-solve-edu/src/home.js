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

    /* A learner returning to an account that already has history skips the
       labelled wait: there is nothing to prepare. */
    if (state.firstActionAt !== null && !shouldFail) { renderHome(); return; }

    finalize(latency, shouldFail);
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

    /* Every destination is focusable, so every destination answers. A control
       that takes focus and does nothing is a dead end; these say why they do
       nothing instead of swallowing the click. */
    var note = $('home_nav_note');
    document.querySelectorAll('.home-nav-item[data-stub]').forEach(function (b) {
      b.addEventListener('click', function () {
        if (!note) return;
        setText('home_nav_note', b.getAttribute('data-stub') + ' is out of scope for this prototype.');
        show('home_nav_note', true);
      });
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
