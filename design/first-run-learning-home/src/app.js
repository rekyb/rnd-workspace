/* Behaviour for the onboarding funnel and first-run Learning Home prototype.
 *
 * Three rules govern this file, all from the PRDs it realizes:
 *
 *  1. No progress figure is a literal. Every number rendered here is read from
 *     window.FRLH or computed from the learner's own state. That is the Slice 12
 *     criterion the legacy funnel prototype fails, where a 1-day streak and a
 *     150-point total are written into the markup.
 *
 *  2. The first action comes from the stored first-course identifier and nothing
 *     else. No activity history, recency list, or popularity ordering is consulted
 *     anywhere in this file, because at first run they have nothing to rank.
 *
 *  3. Step counts derive from one source: FRLH.steps for the current entry path.
 *     The bar and its "Step N of M" text cannot disagree, and the count is correct
 *     for both paths without a hard-coded percentage map.
 */
(function () {
  'use strict';

  var D = window.FRLH;

  /* The learner. initial_course_id is written once, at finalization, and the home
     reads it afterwards; first_action_at is null until the first skill completes,
     which is what makes "first run" a real branch rather than a trivially true one. */
  var learner = null;

  function reset() {
    learner = {
      path: 'organic',
      display_name: '',
      country_code: null,
      age_band: null,
      goal_id: null,
      program_code: null,
      initial_course_id: null,
      first_action_at: null,
      skills_done: 0,
      tasks_done: 0
    };
  }

  function $(id) { return document.getElementById(id); }
  function setText(id, v) { var el = $(id); if (el) el.textContent = v; }

  var SCREENS = ['landing', 'code', 'preview', 'name', 'country', 'age', 'goal',
                 'account', 'loading', 'home', 'skill'];

  function show(name) {
    SCREENS.forEach(function (s) {
      var el = $('s-' + s);
      if (el) el.hidden = s !== name;
    });
    renderProgress(name);
    window.scrollTo(0, 0);
  }

  /* ---- Progress: one source, two renderings ---- */
  function renderProgress(screen) {
    var wrap = $('progress');
    var steps = D.steps[learner.path];
    var idx = steps.indexOf(screen);
    if (idx === -1) { wrap.hidden = true; return; }
    wrap.hidden = false;
    var n = idx + 1;
    var total = steps.length;
    setText('progress-text', 'Step ' + n + ' of ' + total);
    $('progress-fill').style.width = Math.round((n / total) * 100) + '%';
  }

  /* ---- The countable condition, in the same slot as the zero ---- */
  function conditionFor(done, total, noun) {
    if (done === 0) return 'Finish 1 ' + noun.replace(/s$/, '') + ' to see progress here';
    var left = total - done;
    if (left === 0) return 'All ' + total + ' ' + noun + ' complete';
    return left + ' ' + (left === 1 ? noun.replace(/s$/, '') : noun) + ' to go';
  }

  function countFor(done, total, noun) {
    return done + ' of ' + total + ' ' + noun;
  }

  function fill(id, done, total) {
    var el = $(id);
    if (!el) return;
    el.style.width = (!total ? 0 : Math.round((done / total) * 100)) + '%';
  }

  /* ---- Radio groups, built from data ---- */
  function buildRadios(groupId, options) {
    var group = $(groupId);
    group.textContent = '';
    options.forEach(function (opt) {
      var field = document.createElement('label');
      field.className = 'radio-field';

      var item = document.createElement('span');
      item.className = 'radio-item';
      item.setAttribute('data-value', opt.value);
      item.setAttribute('data-state', 'unchecked');

      var ind = document.createElement('span');
      ind.className = 'radio-indicator';
      item.appendChild(ind);

      var label = document.createElement('span');
      label.className = 'radio-label';
      label.textContent = opt.label;

      field.appendChild(item);
      field.appendChild(label);
      group.appendChild(field);
    });
  }

  function buildCountryOptions() {
    var list = $('country-list');
    list.textContent = '';
    D.countries.forEach(function (c) {
      var item = document.createElement('div');
      item.className = 'select-item';
      item.setAttribute('data-value', c.value);
      item.setAttribute('data-state', 'unchecked');
      item.textContent = c.label;
      list.appendChild(item);
    });
  }

  /* ---- Screens ---- */

  function enterCode() {
    learner.path = 'program';
    show('code');
  }

  function submitCode() {
    var raw = $('code-input').value.trim().toUpperCase();
    var program = D.programs[raw];
    var err = $('code-err');
    if (!program) {
      err.textContent = 'That code does not match a program. Check it with your facilitator and try again.';
      err.hidden = false;
      $('code-input').classList.add('err');
      return; /* the entered code is preserved for correction */
    }
    err.hidden = true;
    $('code-input').classList.remove('err');
    learner.program_code = raw;
    setText('prev-name', program.name);
    setText('prev-org', program.organization);

    var caps = $('prev-caps');
    caps.textContent = '';
    program.facilitatorCapabilities.forEach(function (c) {
      var li = document.createElement('li');
      li.className = 'list-item';
      var inner = document.createElement('div');
      inner.className = 'list-item-inner';
      var main = document.createElement('div');
      main.className = 'list-item-main';
      var t = document.createElement('p');
      t.className = 'list-item-title';
      t.textContent = c;
      main.appendChild(t);
      inner.appendChild(main);
      li.appendChild(inner);
      caps.appendChild(li);
    });
    show('preview');
  }

  function finalize() {
    /* The one write that matters: resolve the goal to a course and store it.
       After this the home reads the stored value, so changing the map later
       does not silently change this learner's first action. */
    if (learner.path === 'program') {
      learner.initial_course_id = D.programs[learner.program_code].firstAction.id;
    } else {
      var mapped = D.courseMap[learner.goal_id];
      learner.initial_course_id = mapped ? mapped.id : null;
    }
    show('loading');
    setText('load-greeting', 'Setting things up, ' + learner.display_name);
    /* Slice 12: the skeleton is delayed 400ms before showing, and once shown
       it stays a minimum of 500ms, so it never flashes. */
    var shownAt = Date.now() + 400;
    setTimeout(function () {
      var wait = Math.max(0, shownAt + 500 - Date.now());
      setTimeout(renderHome, wait);
    }, 900);
  }

  function courseFor() {
    if (learner.path === 'program') return D.programs[learner.program_code].firstAction;
    return D.courseMap[learner.goal_id] || null;
  }

  function renderHome() {
    var first = learner.first_action_at === null;
    var course = courseFor();
    var isProgram = learner.path === 'program';

    setText('home-eyebrow', isProgram ? D.programs[learner.program_code].name : 'Your learning home');
    setText('home-greeting', first
      ? 'Ready when you are, ' + learner.display_name
      : 'Good to see you again, ' + learner.display_name);
    setText('home-sub', first
      ? 'You have not started anything yet. Here is where to begin.'
      : 'Picking up where you stopped.');

    /* Unmapped goal: show the empty state, substitute nothing. */
    var unmapped = !course;
    $('home-unmapped').hidden = !unmapped;
    $('home-course-card').hidden = unmapped;

    if (!unmapped) {
      setText('home-course', course.title);
      setText('home-unit', course.unit);
      setText('home-count', countFor(learner.skills_done, course.skills, 'skills'));
      setText('home-condition', conditionFor(learner.skills_done, course.skills, 'skills'));
      fill('home-fill', learner.skills_done, course.skills);
      setText('home-start', (first ? 'Start ' : 'Continue ') + course.title);
    }

    var prog = $('home-program');
    prog.hidden = !isProgram;
    if (isProgram) {
      var p = D.programs[learner.program_code];
      setText('home-program-name', 'Assigned to you');
      setText('home-task-count', countFor(learner.tasks_done, p.tasks.length, 'tasks'));
      setText('home-task-condition', conditionFor(learner.tasks_done, p.tasks.length, 'tasks'));
      fill('home-task-fill', learner.tasks_done, p.tasks.length);

      var list = $('home-task-list');
      list.textContent = '';
      p.tasks.forEach(function (task, i) {
        var li = document.createElement('li');
        li.className = 'list-item';
        var inner = document.createElement('div');
        inner.className = 'list-item-inner';
        var main = document.createElement('div');
        main.className = 'list-item-main';
        var t = document.createElement('p');
        t.className = 'list-item-title';
        t.textContent = task.title;
        main.appendChild(t);
        inner.appendChild(main);
        var trail = document.createElement('span');
        trail.className = 'chip n';
        trail.textContent = i < learner.tasks_done ? 'Done' : (i === learner.tasks_done ? 'Next' : 'Later');
        inner.appendChild(trail);
        li.appendChild(inner);
        list.appendChild(li);
      });
    }

    show('home');
  }

  function openSkill() {
    var course = courseFor();
    setText('skill-eyebrow', course.title);
    setText('skill-title', 'Skill ' + (learner.skills_done + 1) + ' of ' + course.skills);
    show('skill');
  }

  function completeSkill() {
    var course = courseFor();
    if (learner.skills_done < course.skills) learner.skills_done += 1;
    if (learner.path === 'program') {
      var p = D.programs[learner.program_code];
      if (learner.tasks_done < p.tasks.length) learner.tasks_done += 1;
    }
    /* This is what stops every learner being "first run" forever. */
    learner.first_action_at = new Date().toISOString();
    renderHome();
  }

  /* ---- Wiring ---- */
  function gate(btn, ok, readyLabel, blockedLabel) {
    btn.disabled = !ok;
    btn.textContent = ok ? readyLabel : blockedLabel;
  }

  function init() {
    reset();
    buildRadios('age-group', D.ageBands);
    buildRadios('goal-group', D.goals);
    buildCountryOptions();
    if (window.RndUI) window.RndUI.init(document);

    $('go-organic').addEventListener('click', function () {
      learner.path = 'organic';
      show('name');
    });
    $('go-program').addEventListener('click', enterCode);

    document.querySelectorAll('[data-back]').forEach(function (b) {
      b.addEventListener('click', function () { show(b.getAttribute('data-back')); });
    });

    var codeInput = $('code-input');
    codeInput.addEventListener('input', function () {
      gate($('code-submit'), codeInput.value.trim().length === 6,
        'Join this program', 'Enter your 6-character code');
    });
    $('code-submit').addEventListener('click', submitCode);
    $('prev-join').addEventListener('click', function () { show('name'); });

    var nameInput = $('name-input');
    nameInput.addEventListener('input', function () {
      gate($('name-next'), nameInput.value.trim().length >= 2, 'Continue', 'Enter a name to continue');
    });
    $('name-next').addEventListener('click', function () {
      learner.display_name = nameInput.value.trim();
      show('country');
    });

    $('country-trigger').addEventListener('rndui:change', function (e) {
      learner.country_code = e.detail.value;
      gate($('country-next'), true, 'Continue', 'Choose a country to continue');
    });
    $('country-next').addEventListener('click', function () { show('age'); });

    $('age-group').addEventListener('rndui:change', function (e) {
      learner.age_band = e.detail.value;
      gate($('age-next'), true, 'Continue', 'Choose an age range to continue');
    });
    $('age-next').addEventListener('click', function () {
      if (learner.path === 'program') { showAccount(); } else { show('goal'); }
    });

    $('goal-group').addEventListener('rndui:change', function (e) {
      learner.goal_id = e.detail.value;
      gate($('goal-next'), true, 'Continue', 'Choose a goal to continue');
    });
    $('goal-next').addEventListener('click', function () { showAccount(); });

    function showAccount() {
      /* Loss-aversion framing, per litreview F2: the account protects what the
         learner already built rather than gating what they have not started. */
      setText('acct-sub', learner.path === 'program'
        ? 'Create an account to finish joining ' + D.programs[learner.program_code].name + '.'
        : 'You have set up your first course. Create an account so it is still here tomorrow.');
      show('account');
    }

    function acctReady() {
      var email = $('email-input').value.trim();
      var pw = $('pw-input').value;
      var consent = $('consent-box').getAttribute('data-state') === 'checked';
      return email.indexOf('@') > 0 && pw.length >= 8 && consent;
    }
    function syncAcct() {
      gate($('acct-submit'), acctReady(), 'Save my progress', 'Complete the fields to continue');
    }
    $('email-input').addEventListener('input', syncAcct);
    $('pw-input').addEventListener('input', syncAcct);
    $('consent-box').addEventListener('rndui:change', syncAcct);
    $('acct-submit').addEventListener('click', finalize);

    $('home-start').addEventListener('click', openSkill);
    $('skill-done').addEventListener('click', completeSkill);
    $('skill-back').addEventListener('click', renderHome);
    $('unmapped-choose').addEventListener('click', function () { show('goal'); });

    $('restart').addEventListener('click', function () {
      reset();
      ['code-input', 'name-input', 'email-input', 'pw-input'].forEach(function (id) {
        $(id).value = '';
      });
      show('landing');
    });

    show('landing');
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
