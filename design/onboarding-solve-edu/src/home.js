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

  /* Program tasks come from the enrolment payload, not from the markup. */
  var PROGRAM_TASKS = [
    { id: 't1', title: 'Complete your registration', done: true },
    { id: 't2', title: 'Start your first course' },
    { id: 't3', title: 'Finish three skills' },
    { id: 't4', title: 'Complete your program' }
  ];

  var state = null;

  function $(id) { return document.getElementById(id); }
  function setText(id, v) { var el = $(id); if (el) el.textContent = v; }

  function load() {
    var raw = null;
    try { raw = sessionStorage.getItem('se_handoff'); } catch (e) {}
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
        programName: null,
        skillsDone: 0,
        tasksDone: 0,
        firstActionAt: null,
        standalone: true
      };
    }
    return JSON.parse(raw);
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
    $('home_up_next').style.display = mapped ? 'block' : 'none';
    $('home_unmapped').style.display = mapped ? 'none' : 'block';
    $('start-lesson-btn').style.display = mapped ? 'inline-flex' : 'none';

    if (mapped) {
      var done = state.skillsDone;
      var total = state.skillTotal;
      setText('home_course_title', state.courseTitle);
      setText('home_course_unit', 'First unit of your course');
      setText('home_course_count', done + ' of ' + total + ' skills');
      setText('home_course_condition', conditionFor(done, total, 'skill', 'skills'));
      $('home_course_fill').style.width = Math.round((done / total) * 100) + '%';
      setText('start-lesson-btn', (first ? 'Start ' : 'Continue ') + state.courseTitle);
    }

    /* Program tasks */
    var tasks = $('home_program_tasks');
    tasks.style.display = isProgram ? 'block' : 'none';
    if (isProgram) {
      var tDone = state.tasksDone + 1; // registration is complete on arrival
      var tTotal = PROGRAM_TASKS.length;
      setText('home_program_name', state.programName);
      setText('home_program_count', tDone + ' of ' + tTotal + ' tasks');
      setText('home_program_condition', conditionFor(tDone, tTotal, 'task', 'tasks'));

      var list = $('home_task_list');
      list.textContent = '';
      PROGRAM_TASKS.forEach(function (task, i) {
        var complete = task.done || i <= state.tasksDone;
        var row = document.createElement('label');
        row.style.cssText = 'display: flex; align-items: center; gap: 12px; font-size: 15px; font-weight: 500;';
        var box = document.createElement('input');
        box.type = 'checkbox';
        box.disabled = true;
        box.checked = complete;
        box.style.cssText = 'width: 20px; height: 20px; accent-color: var(--green);';
        row.appendChild(box);
        row.appendChild(document.createTextNode(' ' + task.title));
        list.appendChild(row);
      });
    }

    showScreen('learning_home');
  }

  function openSkill() {
    setText('skill_course', state.courseTitle);
    setText('skill_title', 'Skill ' + (state.skillsDone + 1) + ' of ' + state.skillTotal);
    showScreen('skill_screen');
  }

  function completeSkill() {
    if (state.skillsDone < state.skillTotal) state.skillsDone += 1;
    if (state.entryPath === 'program' && state.tasksDone < PROGRAM_TASKS.length - 1) {
      state.tasksDone += 1;
    }
    /* This is what stops every learner being "first run" forever, and what makes
       the returning state reachable in the prototype. */
    state.firstActionAt = new Date().toISOString();
    save();
    renderHome();
  }

  function boot() {
    state = load();
    setText('loading_greeting', 'Setting things up, ' + state.displayName);

    $('start-lesson-btn').addEventListener('click', openSkill);
    $('skill_done_btn').addEventListener('click', completeSkill);
    $('skill_back_btn').addEventListener('click', renderHome);
    $('unmapped_choose_btn').addEventListener('click', function () {
      window.location.href = 'onboarding.html';
    });

    /* A learner returning to an account that already has history skips the
       labelled wait: there is nothing to prepare. */
    if (state.firstActionAt !== null) { renderHome(); return; }

    var shownAt = Date.now() + SKELETON_DELAY_MS;
    setTimeout(function () {
      var hold = Math.max(0, shownAt + SKELETON_MIN_MS - Date.now());
      setTimeout(renderHome, hold);
    }, FAKE_LATENCY_MS);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
