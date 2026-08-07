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
     the Learning Home, so on the chapter screen and in the error state every
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
        chapterTotal: null,
        firstChapterTitle: null,
        firstChapterMinutes: null,
        programName: null,
        chaptersDone: 0,
        tasksDone: 0,
        firstActionAt: null,
        standalone: true,
        programTasks: null,
        taskTotal: null,
        /* Opened directly, so no enrolment was ever resolved. An empty list,
           not a sample course: the switcher shows what the learner is enrolled
           in or it shows nothing. */
        enrolledCourses: []
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
    ['home_loading', 'learning_home', 'chapter_screen'].forEach(function (s) {
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
    /* The denominator moved into this line on 2026-07-31, when the count above
       became a percentage. Slice 12 requires the countable condition AND its
       denominator in the same slot — "0 of 5" carried both, and "0%" carries
       neither, so the denominator has to land somewhere or the criterion fails.
       Here is where it belongs: this is the sentence that says what would move
       the number. */
    if (done === 0) return 'Finish 1 of ' + total + ' ' + many + ' to see progress here';
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

    /* The greeting and its subtitle were removed on 2026-07-31. They were two
       lines of product-owned copy between the learner and their next action,
       and they restated what the action already says. `first` still does real
       work: actionLabel() below reads "Start:" on a first run and "Continue:"
       on a return, so the branch is still observable — it is carried by the
       control the learner is actually going to press rather than by a sentence
       above it. */

    /* Up Next, or the unmapped empty state. Never both, never a substitute. */
    show('home_up_next', mapped);
    show('home_unmapped', !mapped);
    /* Gated on the same boolean as the panels above, so the mapped action and
       the unmapped recovery can never both be filled controls on one screen. */
    show('start-lesson-btn', mapped);
    /* The counter describes the course the dominant object names. With no
       course resolved there is nothing to count, so the slot is not rendered
       rather than rendered at zero against an absent denominator. */
    show('home_course_progress', mapped);

    if (mapped) {
      var done = state.chaptersDone;
      var total = state.chapterTotal;
      setText('home_course_title', state.courseTitle);
      renderCover();

      /* The chosen goal, above the bar. Resolved through the shared lookup so
         the string the home prints is the one the intake screen PRESENTED —
         if the goal set is ever re-worded, both move together. A goal that
         resolves to nothing hides the row rather than printing its raw id,
         which would be leaking a database value at a learner. */
      var goalTitle = typeof window.goalTitleFor === 'function'
        ? window.goalTitleFor(state.goalId)
        : null;
      show('home_course_goal', !!goalTitle);
      /* Exactly one heading, always. The goal chip is the headline when there
         is a goal; the generic title covers the program learner, who has none.
         Neither rendering would leave the slot unlabelled, which is the
         complaint that put a heading here to begin with — and both rendering
         would be two titles for one slot. */
      show('home_course_fallback_title', !goalTitle);
      if (goalTitle) setText('home_course_goal_value', goalTitle);
      /* Was the literal "First unit of your course". Two things were wrong with
         it: "unit" was a third word for the thing the product calls a chapter,
         and the claim was false for any learner past their first — it said
         "First" to someone on chapter 3. Derived from position instead, so it
         cannot go stale. */
      setText('home_course_position', 'Chapter ' + Math.min(done + 1, total) + ' of ' + total);

      /* The bar and the number are ONE computation. They were two expressions
         over the same inputs, which is the drift this project keeps removing —
         a rounding change in one and not the other would put a number beside a
         bar that disagreed with it. */
      var pct = Math.round((done / total) * 100);
      setText('home_course_count', pct + '%');
      setText('home_course_condition', conditionFor(done, total, 'chapter', 'chapters'));
      $('home_course_fill').style.width = pct + '%';
      /* The tracker's heading is no longer written here. It was the course
         name, from data; on 2026-07-31 it became the static label "Your current
         learning path" in home.html. The course name it used to duplicate is
         still set two lines above, on the Up Next card, which is the one place
         the surface now names the course. */
      renderChapters(done);
      /* The action names the chapter it actually opens, which is the one at the
         learner's current position — NOT always chapters[0].

         This was wrong before Slice 18 and invisible: `firstChapterTitle` was the
         only title the handoff carried, so a learner two chapters in saw
         "Continue: Read a bar chart" while openChapter() took them to chapter 3.
         The label and the destination disagreed and nothing on screen could
         show it. The tracker put both on the same screen and the contradiction
         became obvious. Fixed by reading the same list the tracker reads.

         The cost is only known for the first chapter, so it is stated only
         there. That is the existing rule — an unknown duration is omitted,
         never estimated — applied to a case that could not arise before. */
      var nextTitle = courseChapters()[done];
      setText('start-lesson-btn',
        actionLabel(first, nextTitle, done === 0 ? state.firstChapterMinutes : null));
    }

    /* Program tasks. Whether the panel renders is a data question; WHERE it
       renders is a width question, and Slice 16 separates the two. The panel
       lives in the rail at desktop width and returns to the top of the content
       column at 360px, both handled by applyComposition() below. */
    show('home_program_tasks', isProgram);

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

    renderSwitcher();
    /* The search box starts collapsed on every arrival, and its transient note
       AND its result list are cleared. A note left up would follow the learner
       back from the chapter screen, which is the defect the nav note was fixed
       for; a result list left up is the same defect with more on screen, and it
       would sit beside a primary action it had no part in choosing. */
    setAskExpanded(false);
    clearSearch(false);
    applyComposition();

    /* Arriving home means Home is where the learner is. Without this the top
       bar kept marking whichever family they last opened, which is the same
       lie the Home handler used to tell from the other direction. */
    markLocation(null, null);
    showScreen('learning_home');

    /* After showScreen, which clears every note: a learner who opened home.html
       directly is looking at a sample, and the surface has to say so. This line
       used to ride in the greeting subtitle; the greeting is gone and the claim
       is not, because a prototype with no data that looks like a prototype with
       real data is the fabrication class this build exists to remove. */
    if (state.standalone) {
      say('Opened directly, so this is a sample learner. Walk the onboarding to see your own.');
    }
  }

  /* ---- the course tracker (Slice 18) ----
     Enumerates the course's chapters and marks where the learner is. It replaces
     a bare "Course progress" bar that users reported not understanding, and the
     diagnosis was a missing referent: the counter sat in the rail while its
     subject sat in the other column.

     Every row comes from the handoff's courseChapters. A list declared here would
     be the client-side constant Slice 12 removed progress values for, and it
     would also be able to disagree with the denominator — which is why
     main.js now derives chapterTotal from the same array rather than declaring
     it alongside.

     The rows are NOT interactive. `research/PATTERNS.md`'s strongest onboarding
     pattern warns against routing into "another browse surface", and a rail of
     clickable chapters would compete with the primary action it sits beside. */
  function courseChapters() {
    if (Array.isArray(state.courseChapters)) return state.courseChapters;
    /* A handoff written before this field existed. Reconstruct only what is
       actually known — the first chapter's title — and represent the rest as
       unnamed positions rather than inventing names for them. */
    if (state.chapterTotal) {
      var out = [];
      for (var i = 0; i < state.chapterTotal; i++) {
        out.push(i === 0 && state.firstChapterTitle ? state.firstChapterTitle : null);
      }
      return out;
    }
    return [];
  }

  /* ---- the placeholder cover ----
     Keyed to the resolved course by id, from the SAME catalogue the search
     results read. One source for a course's glyph and colour, so the cover on
     the Up Next card and the icon on a search result can never disagree about
     the same course — the two-names-for-one-thing defect this build keeps
     removing, applied to art instead of copy.

     A course the catalogue does not carry — a replayed handoff, or a goal
     mapped after this list was written — gets the neutral cover and its own
     glyph, NOT a borrowed one. Reaching for another course's art to avoid an
     empty band would be inventing a fact about this course. */
  function coverFor(courseId) {
    var catalogue = Array.isArray(window.searchCatalogue) ? window.searchCatalogue : [];
    for (var i = 0; i < catalogue.length; i++) {
      if (catalogue[i].id === courseId) return catalogue[i];
    }
    return null;
  }

  function renderCover() {
    var cover = $('home_course_cover');
    var icon = $('home_course_cover_icon');
    var img = $('home_course_cover_img');
    if (!cover || !icon || !img) return;

    var entry = coverFor(state.initialCourseId);
    icon.textContent = entry ? entry.icon : 'auto_stories';
    /* The tint is the course's own colour at low opacity, so the band reads as
       belonging to this course without competing with the primary action's
       fill a few pixels below it. `color-mix` against the surface rather than a
       second hard-coded value: the card behind it changes with the theme and a
       fixed tint would stop matching in dark mode. */
    cover.style.setProperty('--cover-tint', entry ? entry.color : 'var(--purple)');

    /* THE PHOTOGRAPH IS SHOWN ONLY ONCE IT HAS LOADED, and hidden again if it
       fails. Rendering the img straight away would put a broken-image glyph on
       the dominant object wherever the external host is unreachable — most
       predictably inside a published Artifact, whose CSP blocks it by design.
       Handlers are attached before `src` so a cached image cannot fire load
       before anything is listening. */
    img.classList.add('is-hidden');
    if (!entry || !entry.cover) { img.removeAttribute('src'); return; }

    img.onload = function () { img.classList.remove('is-hidden'); };
    img.onerror = function () { img.classList.add('is-hidden'); };
    img.src = entry.cover;
  }

  function renderChapters(done) {
    var list = $('home_chapter_list');
    if (!list) return;
    list.textContent = '';
    courseChapters().forEach(function (title, i) {
      var li = document.createElement('li');
      var complete = i < done;
      var current = i === done;
      li.className = 'home-chapter' +
        (complete ? ' is-done' : '') +
        (current ? ' is-current' : '');

      var mark = document.createElement('span');
      mark.className = 'home-chapter-mark material-symbols-rounded';
      mark.setAttribute('aria-hidden', 'true');
      mark.textContent = complete ? 'check_circle' : (current ? 'play_circle' : 'circle');
      li.appendChild(mark);

      var name = document.createElement('span');
      name.className = 'home-chapter-name';
      /* A replayed handoff may not name every chapter. "Chapter 3" is the honest
         label for a position whose title we were never given; a plausible
         invented name would be the fabrication class this build removes. */
      name.textContent = title || ('Chapter ' + (i + 1));
      li.appendChild(name);

      /* Completion is carried in TEXT, not colour alone. The current row's
         "Next" chip was REMOVED 2026-07-31 at the product owner's direction: it
         restated what the primary action already says in full a few pixels
         away — "Start: Introduce yourself" — and a second, weaker label for the
         same chapter is the two-names-for-one-thing defect the chapter list was
         restructured to remove.

         SC 1.4.1 still holds without it, and that is the reason it can go: the
         three states differ by GLYPH (check_circle / play_circle / circle), not
         by colour, so a non-colour visual distinction remains. Programmatic
         parity is unaffected — `aria-current="step"` below announces the
         current row as the current step, which is what the removed chip was
         doing for assistive technology anyway. */
      if (complete) {
        var state_ = document.createElement('span');
        state_.className = 'home-chapter-state';
        state_.textContent = 'Done';
        li.appendChild(state_);
      }
      if (current) li.setAttribute('aria-current', 'step');
      list.appendChild(li);
    });
  }

  /* ---- the learner's enrolled courses ----
     Read from the enrolment the handoff carries. A handoff written before this
     field existed is replayed rather than discarded, and the one course
     finalization resolved is reconstructed from the fields that DO exist — so
     the fallback is derived from durable data, not invented. An unmapped goal
     yields an empty list, because a learner with no resolved course is enrolled
     in nothing and a strip is not a place to suggest one. */
  function enrolledCourses() {
    if (Array.isArray(state.enrolledCourses)) return state.enrolledCourses;
    if (state.initialCourseId && state.courseTitle) {
      return [{ id: state.initialCourseId, title: state.courseTitle }];
    }
    return [];
  }

  /* ---- the course switcher ----
     Slice 16. Enrolled courses only. The row is NEVER padded to look fuller:
     a placeholder, locked or suggested course occupying a structural slot is
     promotional content, which section 14 keeps off this surface. With one
     enrolled course it shows that one; with none it does not render.

     Each entry is a real button, so it is reachable by keyboard and exposes
     the course title as its accessible name. The current course is marked with
     aria-current as well as with a class, because a visual-only mark tells
     assistive technology nothing — the same defect the top bar was fixed for.
     None of them is filled: the switcher is not the primary action. */
  function renderSwitcher() {
    var courses = enrolledCourses();
    var row = $('home_switcher_row');
    if (!row) return;
    row.textContent = '';
    /* MORE THAN ONE, not more than none. Changed 2026-07-31 after learners
       reported not knowing what this section was for.

       Slice 16's criterion always allowed both arms — "either shows that one
       course or is not rendered" — and this build took the wrong one. With a
       single enrolment the section was a plural heading over one chip that
       named the course already titled in the card directly above it, marked
       with an ambiguous word, and answering every click with "you are already
       in it". A control with one option is not a control; it is a label, and a
       duplicate one.

       §11.1 had already written the argument down — "at first run it holds one
       course, so it earns no vertical space" — and scoped it to 360px. Nothing
       in that sentence is about width. It is about N=1, so it holds at every
       width, and the switcher now appears exactly when it becomes a switcher.

       The condition is on the DATA, not on first-run: a returning learner with
       one enrolment has nothing to switch between either. */
    show('home_switcher', courses.length > 1);
    if (courses.length < 2) return;

    courses.forEach(function (course) {
      var isCurrent = course.id === state.initialCourseId;
      var b = document.createElement('button');
      b.type = 'button';
      b.className = 'home-switcher-item' + (isCurrent ? ' is-current' : '');
      b.textContent = course.title;
      if (isCurrent) {
        b.setAttribute('aria-current', 'true');
        /* The mark is stated in text too. A learner who cannot resolve the
           border treatment still learns which course they are in.

           "Current", not "Open": the old word read as an imperative — a thing
           to do rather than a state the chip is in — on a control that then
           refused to do it. */
        var mark = document.createElement('span');
        mark.className = 'home-switcher-mark';
        mark.textContent = 'Current';
        b.appendChild(mark);
      }
      b.addEventListener('click', function () {
        say(course.title + ' is the course you are already in.');
      });
      row.appendChild(b);
    });
  }

  /* ---- the search entry point (Slice 17, revised by Slice 19) ----
     Slice 17 shipped this as a question box that recorded and answered
     nothing. Cycle 7 overturned two of its three prohibitions at the product
     owner's direction: starters and a SIMULATED result list are now in scope.

     THE THIRD PROHIBITION IS UNTOUCHED AND IS WHY THIS BLOCK IS STILL SAFE.
     Nothing below writes initialCourseId, courseTitle, firstChapterTitle,
     chapterTotal or chaptersDone. If searching could re-point Up Next, Slice
     13's determinism criterion is dead and §2.1 F3's disposition would have to
     change rather than merely be re-examined. Activating a result therefore
     says opening a course is out of scope; it does not route, and it does not
     re-resolve the enrolment.

     WHAT KEEPS THE SIMULATION FROM BEING A FABRICATION is a label at the point
     of use, not a caveat elsewhere. The result list states that its catalogue
     is placeholder content every time it renders, and a query matching nothing
     says so rather than falling back to a default set. §14 still excludes the
     real retrieval service; what is under test is the shape of the surface. */
  function recentSearches() {
    return Array.isArray(state.searchQueries) ? state.searchQueries : [];
  }

  /* The starters are a declared constant, identical for every learner. They
     are NOT derived from the goal answer, the enrolment, or anything typed —
     deriving them would make this the ranking surface §14 still excludes, and
     would make the "no personalization" claim in §9 untestable. */
  function renderStarters() {
    var box = $('home_ask_starters');
    if (!box) return;
    box.textContent = '';

    var starters = Array.isArray(window.searchStarters) ? window.searchStarters : [];
    if (!starters.length) return;

    var title = document.createElement('p');
    title.className = 'home-ask-starters-title';
    title.id = 'home_ask_starters_title';
    title.textContent = 'Not sure what to type?';
    box.appendChild(title);

    var list = document.createElement('div');
    list.className = 'home-ask-starters-list';
    /* Labelled by the line above rather than by a repeated per-button
       explanation: a screen-reader user meets the group's purpose once. */
    list.setAttribute('role', 'group');
    list.setAttribute('aria-labelledby', 'home_ask_starters_title');

    starters.forEach(function (text) {
      var chip = document.createElement('button');
      chip.type = 'button';
      chip.className = 'home-ask-starter';
      chip.textContent = text;
      /* FILLS, does not search. A control that wrote the phrase and submitted
         it in the same click would deny the learner the edit the starter
         exists to make cheap. */
      chip.addEventListener('click', function () {
        var input = $('home_ask_input');
        if (!input) return;
        input.value = text;
        syncClearButton();
        input.focus();
        setText('home_ask_note', 'Edit it if you like, then ask.');
      });
      list.appendChild(chip);
    });
    box.appendChild(list);
  }

  /* The clear affordance only exists while there is something to clear. A
     permanently visible clear button on an empty field is a control that does
     nothing, which is the dead-end class this build removes elsewhere. */
  function syncClearButton() {
    var input = $('home_ask_input');
    var clear = $('home_ask_clear');
    if (!input || !clear) return;
    clear.classList.toggle('is-hidden', !input.value);
  }

  /* One card. Built here rather than inline twice, so a match and a related
     course are structurally identical and only their HEADING distinguishes
     them — the difference is a claim about relevance, and it belongs in words
     rather than in a treatment a learner has to decode. */
  function resultCard(course) {
    var card = document.createElement('button');
    card.type = 'button';
    /* Not filled. The one-filled-control invariant is counted across both
       columns and the primary action on the dominant object owns the fill —
       three result cards competing with it would be the exact reading Slice 13
       is written to prevent. */
    card.className = 'home-ask-result';

    var icon = document.createElement('span');
    icon.className = 'home-ask-result-icon material-symbols-rounded';
    icon.setAttribute('aria-hidden', 'true');
    icon.textContent = course.icon;
    icon.style.color = course.color;
    card.appendChild(icon);

    var body = document.createElement('span');
    body.className = 'home-ask-result-body';

    var title = document.createElement('span');
    title.className = 'home-ask-result-title';
    title.textContent = course.title;
    body.appendChild(title);

    /* The cost line states only what the catalogue carries. A course with no
       duration states none rather than an estimated one — the same rule the
       primary action's label follows. */
    var meta = document.createElement('span');
    meta.className = 'home-ask-result-meta';
    var hasCost = typeof course.minutes === 'number' && course.minutes > 0;
    meta.textContent = course.chapters + ' chapters' +
      (hasCost ? ' · ' + course.minutes + ' min first chapter' : '');
    body.appendChild(meta);

    card.appendChild(body);

    /* Inert by design, and it says so. Routing here would need a course
       catalogue and a lesson player, both §14 non-goals; re-pointing Up Next
       instead would break Slice 13. Saying so is the third option and the only
       honest one at this appetite. */
    card.addEventListener('click', function () {
      setText('home_ask_note',
        'Opening a course is out of scope for this prototype, so nothing was started. Your next chapter is unchanged.');
    });

    return card;
  }

  function resultList(courses) {
    var list = document.createElement('ul');
    list.className = 'home-ask-results-list';
    courses.forEach(function (course) {
      var li = document.createElement('li');
      li.appendChild(resultCard(course));
      list.appendChild(li);
    });
    return list;
  }

  function renderResults(query, results) {
    var box = $('home_ask_results');
    if (!box) return;
    box.textContent = '';

    var matches = results.matches || [];
    var related = results.related || [];

    var head = document.createElement('p');
    head.className = 'home-ask-results-head';

    if (!matches.length) {
      /* No substitute set. Returning the whole catalogue when nothing matched
         would present nine non-matches as answers, which is the failure this
         surface is labelled against. */
      head.textContent = 'Nothing in this placeholder set matches "' + query + '".';
      box.appendChild(head);

      var alt = document.createElement('p');
      alt.className = 'home-ask-results-note';
      alt.textContent = 'Try one of the starters above, or a single word such as English, math, money, or data.';
      box.appendChild(alt);
      return;
    }

    /* The count is of MATCHES only. Adding the related courses to it would
       state a relevance the match never established, which is precisely the
       claim this slot is not allowed to make. */
    head.textContent = matches.length + (matches.length === 1 ? ' course matches "' : ' courses match "') + query + '"';
    box.appendChild(head);

    /* THE LABEL THAT MAKES THIS HONEST, and it renders with the results rather
       than once at the top of the page: a reader who scrolled to a card must
       be able to see from there that the card is placeholder content. */
    var caveat = document.createElement('p');
    caveat.className = 'home-ask-results-note';
    caveat.textContent = 'Simulated catalogue — placeholder content for this prototype, not the real course list or its ranking.';
    box.appendChild(caveat);

    box.appendChild(resultList(matches));

    /* The related set gets its OWN heading, and the heading says what it is:
       these did not match, they share a topic with something that did. An
       unlabelled fill-in is a match the learner was never told was a guess. */
    if (related.length) {
      var relHead = document.createElement('p');
      relHead.className = 'home-ask-results-subhead';
      relHead.textContent = 'Related in this placeholder set';
      box.appendChild(relHead);
      box.appendChild(resultList(related));
    }
  }

  function renderAskRecent() {
    var box = $('home_ask_recent');
    if (!box) return;
    box.textContent = '';
    var recent = recentSearches();

    if (!recent.length) {
      /* The zero state says there is nothing yet, and it is NOT filled with
         the starters above: those are a constant and this list is the
         learner's own input, so merging them would make this slot a lie for
         anyone who has searched nothing. */
      var empty = document.createElement('p');
      empty.className = 'home-ask-empty';
      empty.textContent = 'Searches you run will appear here.';
      box.appendChild(empty);
      return;
    }

    var title = document.createElement('p');
    title.className = 'home-ask-recent-title';
    title.textContent = 'Your recent searches';
    box.appendChild(title);

    var list = document.createElement('ul');
    list.className = 'home-ask-recent-list';
    /* Most recent first, and the learner's own input replayed — never a
       constant, which would make the empty state above a lie for anyone who
       had searched nothing. */
    recent.slice().reverse().forEach(function (q) {
      var li = document.createElement('li');
      li.className = 'home-ask-recent-item';
      li.textContent = q;
      list.appendChild(li);
    });
    box.appendChild(list);
  }

  /* The input IS the trigger since 2026-07-31, so `aria-expanded` lives on it
     rather than on a button above it, and expanding does not move focus — the
     learner is already in the field they are about to type into. Focusing it
     from here would be a no-op at best and, when the expansion is triggered BY
     the focus event, a re-entrant one. */
  function setAskExpanded(on) {
    var input = $('home_ask_input');
    show('home_ask_box', on);
    if (input) input.setAttribute('aria-expanded', on ? 'true' : 'false');
    if (on) {
      renderStarters();
      renderAskRecent();
      syncClearButton();
    }
  }

  /* A control that expands with no way back is a trap — the same defect the
     navigation panels were fixed for, so it is answered the same way. Focus
     returns to the field, which is both the trigger and the thing the learner
     was last working in. */
  function collapseAsk(returnFocus) {
    setAskExpanded(false);
    if (returnFocus) {
      var input = $('home_ask_input');
      if (input) input.focus();
    }
  }

  /* Empties the field AND the results. Clearing the query while its results
     stayed on screen would leave the surface asserting a match for a phrase
     that is no longer there. */
  function clearSearch(returnFocus) {
    var input = $('home_ask_input');
    if (input) input.value = '';
    setText('home_ask_note', '');
    var results = $('home_ask_results');
    if (results) results.textContent = '';
    syncClearButton();
    if (returnFocus && input) input.focus();
  }

  function submitAsk() {
    var input = $('home_ask_input');
    if (!input) return;
    var q = input.value.trim();
    if (!q) {
      setText('home_ask_note', 'Type what you want to learn, or pick a starter above.');
      return;
    }

    /* Recorded, then matched against the placeholder set. No ranker and no
       service is consulted, and the fields the primary action reads are not
       touched here — the determinism criterion is enforced by this function
       containing no assignment to any of them.

       A REPEATED QUERY MOVES, it does not accumulate. Asking the same thing
       twice is one thing the learner wants, and a list showing it twice spends
       the slot's whole height saying so — which at three or four repeats
       pushes their earlier, different searches out of view entirely. Dropping
       the older copy keeps this the learner's own input; it is the same
       string, in its newest position. */
    state.searchQueries = recentSearches().filter(function (prev) {
      return prev.toLowerCase() !== q.toLowerCase();
    }).concat([q]);
    save();

    var results = typeof window.searchCourses === 'function'
      ? window.searchCourses(q)
      : { matches: [], related: [] };

    /* Asking opens the panel if it is closed. Enter reaches this function from
       the field whether or not the panel is up, and rendering results into a
       hidden container would be the silent no-op the nav note was fixed for. */
    setAskExpanded(true);
    renderResults(q, results);
    setText('home_ask_note', '');
    renderAskRecent();
  }

  /* ---- the composition, per width ----
     PRD 11.1's Cycle 4 and Cycle 5 rows, executed rather than described. The
     rail is a two-column device and there is one column at 360px, so the
     region is DROPPED there and each of its slots takes a disposition of its
     own:

       - the course-progress counter RELOCATES back onto the Up Next card, its
         Cycle 2 position, because it describes the course that card names and
         the two should not be separated when one column can hold both;
       - the program card RELOCATES to the top of the content column, where
         11.1 already makes assigned work the dominant object for a program
         learner;
       - the switcher is SUB-LEVELLED behind the navigation, because at first
         run it holds one course and earns no vertical space in a single
         column. It is not dropped: a learner with a second course still
         reaches it through Learn, which is where courses already live;
       - the Ask field is KEPT, and kept ABOVE the dominant object. It is the
         only slot on this surface that outranks the learner's own work at
         narrow width, and PRD 11.1 states the reason rather than assuming it:
         it is an input, not a signal, and an input pushed below a card and a
         task list is one nobody finds on a phone. This is a deliberate
         exception to Slice 12's ordinal criterion and is the first thing to
         reverse if the first-click test shows the field taking clicks from
         the primary action.

     Each node is MOVED, never duplicated. Rendering a second copy at the other
     width would fail Slice 16's relocation criterion, which is deliberately
     stated as a count of one.

     Slice 16's `Courses` destination does not exist in the settled navigation:
     the top-nav IA landed on 2026-07-30 with four families, and the catalogue
     sits at Learn > Catalog. The disposition is honoured against that
     destination instead. Recorded rather than silently re-mapped. */
  var NARROW = '(max-width: 767px)';

  function applyComposition() {
    var narrow = window.matchMedia(NARROW).matches;
    var rail = $('home_rail');
    var col = $('home_content_col');
    var counter = $('home_course_progress');
    var program = $('home_program_tasks');
    var upNext = $('home_up_next');
    var ask = $('home_ask');
    if (!rail || !col || !counter || !program || !upNext || !ask) return;

    if (narrow) {
      /* Before the action, not after it. The Cycle 2 order on this card was
         title, unit, counter, then the control — appending would put the
         counter below the button and read as a footnote to it rather than as
         a description of the course above. */
      upNext.insertBefore(counter, $('start-lesson-btn'));
      col.insertBefore(program, col.firstChild);
      /* Inserted after the program card and at the same position, so it ends
         up ahead of it: Ask, then assigned work, then Up Next. */
      col.insertBefore(ask, col.firstChild);
      show('home_switcher', false);
    } else {
      rail.insertBefore(program, rail.firstChild);
      rail.appendChild(counter);
      rail.insertBefore(ask, rail.firstChild);
      show('home_switcher', enrolledCourses().length > 1);
    }

    /* An empty rail is not rendered as an empty box. Since Slice 17 the Ask
       field always renders, so at desktop width the rail is never empty and
       the only case left is the region being dropped at narrow width. The
       per-slot test is kept rather than collapsed to `!narrow`, because it is
       what would catch a future slot set where every member is conditional. */
    var railHasContent = !narrow && (
      !ask.classList.contains('is-hidden') ||
      !program.classList.contains('is-hidden') ||
      !counter.classList.contains('is-hidden'));
    show('home_rail', railHasContent);
  }

  function openChapter() {
    setText('chapter_course', state.courseTitle + ' · chapter ' + (state.chaptersDone + 1) + ' of ' + state.chapterTotal);
    /* The destination names the same item the action named. Since Slice 18 the
       handoff carries every chapter's title, not just the first, so a learner on
       chapter 3 sees its name instead of "Chapter 3". The positional fallback stays
       for a replayed handoff that predates the list — an honest position beats
       a borrowed name. */
    var current = courseChapters()[state.chaptersDone];
    setText('chapter_title', current || ('Chapter ' + (state.chaptersDone + 1)));
    /* A lesson lives under Learn, so that is the family the bar marks while the
       learner is in one. Without this the bar kept whichever family they had
       opened on the way out. */
    markLocation('learn', null);
    showScreen('chapter_screen');
  }

  function completeChapter() {
    if (state.chaptersDone < state.chapterTotal) state.chaptersDone += 1;
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
  var XP_PER_CHAPTER = 20;

  function renderXp() {
    var xp = (state && typeof state.chaptersDone === 'number') ? state.chaptersDone * XP_PER_CHAPTER : 0;
    var nodes = document.querySelectorAll('[id^="home_xp_value"]');
    Array.prototype.forEach.call(nodes, function (n) { n.textContent = String(xp); });
  }

  /* ---- theme ----
     A tonal variant, applied by re-pointing surface and text tokens on the root
     element.

     It is a switch now, not a push button, and that changes what each part
     carries. A button's label has to state the ACTION, because a button has no
     state to read; a switch has one, so the label names the SETTING and
     aria-checked carries which way it is set. "Dark mode" is the setting name
     nearly every product uses for this, and against a switch it needs no
     qualifier: on means dark.

     Nothing here rewrites the label or the icon. An earlier version flipped the
     moon to a sun when dark was on, which contradicted the label sitting beside
     it — a sun next to "Dark mode, on" reads as the opposite of the state. The
     state is carried by aria-checked and by the knob's POSITION, which is not a
     colour, so SC 1.4.1 holds without a second signal that disagrees. */
  function applyTheme(dark) {
    var root = document.documentElement;
    if (dark) { root.setAttribute('data-theme', 'dark'); }
    else { root.removeAttribute('data-theme'); }
    try { localStorage.setItem('se_theme', dark ? 'dark' : 'light'); } catch (e) {}
    var btns = document.querySelectorAll('[id^="theme_btn"]');
    Array.prototype.forEach.call(btns, function (b) {
      b.setAttribute('aria-checked', dark ? 'true' : 'false');
    });
  }

  /* ---- language ----
     The profile row is a trigger; the choice itself happens in a page-level
     dialog. A panel opening out of the profile panel would be the second level
     of depth the top bar exists to avoid, and it would put the list back inside
     the panel's stacking context — the failure that buried the family panels
     behind the content column.

     The prototype records the choice and says what did not happen; the string
     catalogue is out of scope, so the control does not pretend the interface
     translated. */
  function applyLang(code) {
    var name = code === 'id' ? 'Bahasa Indonesia' : 'English';
    try { localStorage.setItem('se_lang', code); } catch (e) {}
    /* Every view's trigger carries the choice, so opening the menu on the chapter
       screen shows the same language the learner picked on the home. */
    var names = document.querySelectorAll('[id^="lang_name"]');
    Array.prototype.forEach.call(names, function (n) { n.textContent = name; });
    var triggers = document.querySelectorAll('[id^="lang_btn"]');
    Array.prototype.forEach.call(triggers, function (b) {
      /* The visible text is the language alone, so the accessible name has to
         supply what the row IS. It still contains the visible string (SC 2.5.3),
         which is what keeps speech input working. */
      b.setAttribute('aria-label', 'Change language, currently ' + name);
    });
    /* aria-current is the selection; the tick is only its visible half. Marking
       one without the other is how a list ends up looking right and announcing
       nothing. */
    var opts = document.querySelectorAll('.lang-option');
    Array.prototype.forEach.call(opts, function (o) {
      if (o.getAttribute('data-lang') === code) { o.setAttribute('aria-current', 'true'); }
      else { o.removeAttribute('aria-current'); }
    });
    /* The document's lang attribute is deliberately NOT changed. Declaring
       lang="id" over English copy is a WCAG 3.1.1 falsehood: a screen reader
       would voice English strings with Indonesian phonemes. The preference is
       recorded; the interface has not translated, and the message says so. */
    say(name + ' selected. Interface strings are out of scope for this prototype.');
  }

  /* ---- the language dialog ----
     A modal, so three things are mandatory rather than nice to have: focus goes
     in, focus cannot leave while it is open, and focus comes back on close.
     Without the third a keyboard learner is returned to the top of the document
     and has to walk the whole bar again.

     Where focus returns is not the trigger. The trigger lives inside the
     profile menu, and opening the dialog closes that menu, so restoring focus
     to it would put focus on a display:none element — which browsers resolve by
     dropping focus to <body>, the exact failure this is meant to prevent. It
     returns to the profile control in the active view, which is visible, is one
     keystroke from reopening the menu, and is where the learner started. */
  var langReturnFocus = null;

  function focusablesIn(root) {
    return Array.prototype.filter.call(
      root.querySelectorAll('button, [href], input, select, textarea, [tabindex]'),
      function (el) { return !el.disabled && el.getAttribute('tabindex') !== '-1'; }
    );
  }

  function langModalOpen() {
    var m = $('lang_modal');
    return !!m && m.classList.contains('show');
  }

  function openLangModal() {
    var m = $('lang_modal');
    if (!m) return;
    /* The menu closes first. A panel left open behind a backdrop is unreachable
       but still in the tab order, which is worse than either state alone. */
    closeAllPanels();
    var card = document.querySelector('.home-card.active');
    langReturnFocus = card ? card.querySelector('[data-family="profile"]') : null;
    m.classList.add('show');
    /* Focus the current choice rather than the first: it tells the learner
       where they are before it asks them to change it. */
    var current = m.querySelector('.lang-option[aria-current="true"]') || m.querySelector('.lang-option');
    if (current) current.focus();
  }

  function closeLangModal() {
    var m = $('lang_modal');
    if (!m || !m.classList.contains('show')) return;
    m.classList.remove('show');
    if (langReturnFocus && document.contains(langReturnFocus)) langReturnFocus.focus();
    langReturnFocus = null;
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
    $('start-lesson-btn').addEventListener('click', openChapter);
    $('chapter_done_btn').addEventListener('click', completeChapter);
    $('chapter_back_btn').addEventListener('click', renderHome);
    $('unmapped_choose_btn').addEventListener('click', function () {
      window.location.href = 'onboarding.html';
    });
    $('home_retry_btn').addEventListener('click', function () {
      window.location.href = window.location.pathname;
    });

    /* ---- Search (Slice 17, revised by Slice 19) ----
       Every listener here expands, collapses, fills, clears, or searches the
       placeholder set. None of them reads or writes the course the primary
       action resolves to. */
    var askInput = $('home_ask_input');
    var askBox = $('home_ask_box');
    if (askInput && askBox) {
      /* FOCUS opens it, not a click. Tabbing into the field has to open the
         panel too, or a keyboard learner reaches the input and never learns the
         starters below it exist. */
      askInput.addEventListener('focus', function () { setAskExpanded(true); });
      /* The field and the panel are both inside the rail, and the
         document-level handler that closes navigation panels would otherwise
         treat every click and keystroke target inside them as an outside click
         on the way up. */
      askInput.addEventListener('click', function (e) {
        e.stopPropagation();
        setAskExpanded(true);
      });
      askBox.addEventListener('click', function (e) { e.stopPropagation(); });
      askBox.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') { e.stopPropagation(); collapseAsk(true); }
      });
      $('home_ask_submit').addEventListener('click', submitAsk);
      $('home_ask_clear').addEventListener('click', function () { clearSearch(true); });

      askInput.addEventListener('keydown', function (e) {
        /* Escape from the field itself, not only from the panel below it. The
           learner is standing in the trigger, so this is the likeliest place
           they press it. */
        if (e.key === 'Escape') { e.stopPropagation(); collapseAsk(true); }
        /* Enter searches. A search field whose only submit path is a button
           the learner has to travel to is one they will press Enter at
           anyway, and doing nothing then reads as a broken field. */
        if (e.key === 'Enter') { e.preventDefault(); submitAsk(); }
      });
      /* Typing maintains the clear affordance and re-opens the panel, and
         NOTHING ELSE. No results are computed here: live results would be the
         typeahead Slice 17 excluded, and Cycle 7's overturn covered starters
         and an explicit-ask result list, not completion while typing.

         WHY THE RE-OPEN IS HERE. Escape closes the panel and leaves focus in
         the field, which is correct — but `focus` cannot fire again on an
         element that never lost it, so a keyboard learner who pressed Escape
         and then carried on typing had no way back to the starters short of
         tabbing away and back. Pointer users were already covered by the click
         handler above; this is the same recovery for the keyboard. */
      askInput.addEventListener('input', function () {
        syncClearButton();
        setAskExpanded(true);
      });
    }

    /* Every [data-family] control, not just the ones styled as nav items. This
       was a live bug when the language switch was a .home-icon-btn in the bar:
       a .home-nav-item selector left it unbound and its panel never opened. The
       language switch has since moved into the profile menu and all four
       remaining triggers are nav items, so the broad selector is now insurance
       rather than a fix — kept because the next utility control added to the bar
       will not be a nav item either. Four panels per view. */
    var famTriggers = document.querySelectorAll('[data-family]');
    Array.prototype.forEach.call(famTriggers, function (t) {
      t.addEventListener('click', function (e) { e.stopPropagation(); openFamily(t); });
    });
    /* The disposition table is applied at the breakpoint, not only on load. A
       learner who rotates a tablet crosses 767px without a reload, and a
       composition applied once would strand the counter in a rail that is no
       longer rendered. addListener is the pre-2020 Safari spelling and is kept
       because the target is Android mobile web, not a modern-browser-only
       demo. */
    var mq = window.matchMedia(NARROW);
    if (mq.addEventListener) { mq.addEventListener('change', applyComposition); }
    else if (mq.addListener) { mq.addListener(applyComposition); }

    /* A click anywhere else, or Escape, closes an open panel. Without both, the
       panel is a trap: it opens on click and has no dismissal. */
    document.addEventListener('click', closeAllPanels);
    document.addEventListener('keydown', function (e) {
      /* The dialog is the innermost layer, so Escape belongs to it first. One
         key press closes one thing: without this it would dismiss the dialog and
         the panels underneath in the same stroke. */
      if (e.key === 'Escape' && langModalOpen()) { closeLangModal(); return; }
      if (e.key === 'Escape') closeAllPanels();
    });

    var themeBtns = document.querySelectorAll('[id^="theme_btn"]');
    Array.prototype.forEach.call(themeBtns, function (b) {
      b.addEventListener('click', function (e) {
        e.stopPropagation();
        applyTheme(document.documentElement.getAttribute('data-theme') !== 'dark');
      });
    });

    /* The trigger swallows its own click so the document handler does not close
       the menu on the way up — openLangModal closes it deliberately instead, in
       an order that leaves nothing focusable behind the backdrop. */
    var langTriggers = document.querySelectorAll('[id^="lang_btn"]');
    Array.prototype.forEach.call(langTriggers, function (b) {
      b.addEventListener('click', function (e) { e.stopPropagation(); openLangModal(); });
    });

    var langModal = $('lang_modal');
    if (langModal) {
      var langCard = langModal.querySelector('.modal-content');
      /* Three dismissals, because the modal-container row of the PRD's
         narrow-width dictionary forbids depending on the backdrop alone: an
         explicit Close inside the dialog's own bounds, the backdrop, and
         Escape. */
      $('lang_modal_close').addEventListener('click', closeLangModal);
      langModal.addEventListener('click', closeLangModal);
      langCard.addEventListener('click', function (e) { e.stopPropagation(); });

      /* The trap. Tab from the last focusable wraps to the first and
         Shift+Tab from the first wraps to the last, so focus cannot walk out
         into a page that is inert to the eye but not to the keyboard. */
      langCard.addEventListener('keydown', function (e) {
        if (e.key !== 'Tab') return;
        var items = focusablesIn(langCard);
        if (!items.length) return;
        var firstEl = items[0], lastEl = items[items.length - 1];
        if (e.shiftKey && document.activeElement === firstEl) { e.preventDefault(); lastEl.focus(); }
        else if (!e.shiftKey && document.activeElement === lastEl) { e.preventDefault(); firstEl.focus(); }
      });

      var langOptions = langModal.querySelectorAll('.lang-option');
      Array.prototype.forEach.call(langOptions, function (o) {
        o.addEventListener('click', function (e) {
          e.stopPropagation();
          /* Close before applying. applyLang writes into the note at the top of
             the content column, and announcing behind a backdrop announces to
             nobody. */
          closeLangModal();
          applyLang(o.getAttribute('data-lang'));
        });
      });
    }

    /* Every destination is focusable, so every destination answers — the panel
       members and the profile menu too, not only the top row. A control that
       takes focus and does nothing is a dead end; these say why they do nothing
       instead of swallowing the click. */
    var stubs = document.querySelectorAll('[data-stub]');
    Array.prototype.forEach.call(stubs, function (b) {
      b.addEventListener('click', function () {
        var name = b.getAttribute('data-stub');
        /* Home navigates. Marking it current without changing the view made the
           one signal this whole change exists to add tell a lie: on the chapter
           screen it claimed the learner was on Home while the chapter screen was
           still rendered. */
        if (name === 'Home') { hideNote(); renderHome(); return; }
        /* Log out ends the session and returns to the funnel entry.
           The handoff is CLEARED first. Navigating without clearing it would
           leave the learner one back-button away from their own logged-out
           home, which is a logout that did not log anything out — and the
           prototype would then be demonstrating a security bug rather than a
           flow.
           localStorage is deliberately left alone. Theme and language are
           device preferences, not account data: clearing them would drop a
           learner onto the onboarding in English and light mode, which for an
           audience that may not read English is the one place it hurts most. */
        if (name === 'Log out') {
          try { sessionStorage.removeItem('se_handoff'); } catch (e) {}
          window.location.href = 'onboarding.html';
          return;
        }
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
