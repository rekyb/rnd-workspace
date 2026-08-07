const allCountries = [
  { name: "Afghanistan", code: "af" },
  { name: "Albania", code: "al" },
  { name: "Algeria", code: "dz" },
  { name: "Andorra", code: "ad" },
  { name: "Angola", code: "ao" },
  { name: "Antigua and Barbuda", code: "ag" },
  { name: "Argentina", code: "ar" },
  { name: "Armenia", code: "am" },
  { name: "Australia", code: "au" },
  { name: "Austria", code: "at" },
  { name: "Azerbaijan", code: "az" },
  { name: "Bahamas", code: "bs" },
  { name: "Bahrain", code: "bh" },
  { name: "Bangladesh", code: "bd" },
  { name: "Barbados", code: "bb" },
  { name: "Belarus", code: "by" },
  { name: "Belgium", code: "be" },
  { name: "Belize", code: "bz" },
  { name: "Benin", code: "bj" },
  { name: "Bhutan", code: "bt" },
  { name: "Bolivia", code: "bo" },
  { name: "Bosnia and Herzegovina", code: "ba" },
  { name: "Botswana", code: "bw" },
  { name: "Brazil", code: "br" },
  { name: "Brunei", code: "bn" },
  { name: "Bulgaria", code: "bg" },
  { name: "Burkina Faso", code: "bf" },
  { name: "Burundi", code: "bi" },
  { name: "Côte d'Ivoire", code: "ci" },
  { name: "Cabo Verde", code: "cv" },
  { name: "Cambodia", code: "kh" },
  { name: "Cameroon", code: "cm" },
  { name: "Canada", code: "ca" },
  { name: "Central African Republic", code: "cf" },
  { name: "Chad", code: "td" },
  { name: "Chile", code: "cl" },
  { name: "China", code: "cn" },
  { name: "Colombia", code: "co" },
  { name: "Comoros", code: "km" },
  { name: "Congo", code: "cg" },
  { name: "Costa Rica", code: "cr" },
  { name: "Croatia", code: "hr" },
  { name: "Cuba", code: "cu" },
  { name: "Cyprus", code: "cy" },
  { name: "Czech Republic", code: "cz" },
  { name: "Democratic Republic of the Congo", code: "cd" },
  { name: "Denmark", code: "dk" },
  { name: "Djibouti", code: "dj" },
  { name: "Dominica", code: "dm" },
  { name: "Dominican Republic", code: "do" },
  { name: "Ecuador", code: "ec" },
  { name: "Egypt", code: "eg" },
  { name: "El Salvador", code: "sv" },
  { name: "Equatorial Guinea", code: "gq" },
  { name: "Eritrea", code: "er" },
  { name: "Estonia", code: "ee" },
  { name: "Eswatini", code: "sz" },
  { name: "Ethiopia", code: "et" },
  { name: "Fiji", code: "fj" },
  { name: "Finland", code: "fi" },
  { name: "France", code: "fr" },
  { name: "Gabon", code: "ga" },
  { name: "Gambia", code: "gm" },
  { name: "Georgia", code: "ge" },
  { name: "Germany", code: "de" },
  { name: "Ghana", code: "gh" },
  { name: "Greece", code: "gr" },
  { name: "Grenada", code: "gd" },
  { name: "Guatemala", code: "gt" },
  { name: "Guinea", code: "gn" },
  { name: "Guinea-Bissau", code: "gw" },
  { name: "Guyana", code: "gy" },
  { name: "Haiti", code: "ht" },
  { name: "Holy See", code: "va" },
  { name: "Honduras", code: "hn" },
  { name: "Hungary", code: "hu" },
  { name: "Iceland", code: "is" },
  { name: "India", code: "in" },
  { name: "Indonesia", code: "id" },
  { name: "Iran", code: "ir" },
  { name: "Iraq", code: "iq" },
  { name: "Ireland", code: "ie" },
  { name: "Israel", code: "il" },
  { name: "Italy", code: "it" },
  { name: "Jamaica", code: "jm" },
  { name: "Japan", code: "jp" },
  { name: "Jordan", code: "jo" },
  { name: "Kazakhstan", code: "kz" },
  { name: "Kenya", code: "ke" },
  { name: "Kiribati", code: "ki" },
  { name: "Kuwait", code: "kw" },
  { name: "Kyrgyzstan", code: "kg" },
  { name: "Laos", code: "la" },
  { name: "Latvia", code: "lv" },
  { name: "Lebanon", code: "lb" },
  { name: "Lesotho", code: "ls" },
  { name: "Liberia", code: "lr" },
  { name: "Libya", code: "ly" },
  { name: "Liechtenstein", code: "li" },
  { name: "Lithuania", code: "lt" },
  { name: "Luxembourg", code: "lu" },
  { name: "Madagascar", code: "mg" },
  { name: "Malawi", code: "mw" },
  { name: "Malaysia", code: "my" },
  { name: "Maldives", code: "mv" },
  { name: "Mali", code: "ml" },
  { name: "Malta", code: "mt" },
  { name: "Marshall Islands", code: "mh" },
  { name: "Mauritania", code: "mr" },
  { name: "Mauritius", code: "mu" },
  { name: "Mexico", code: "mx" },
  { name: "Micronesia", code: "fm" },
  { name: "Moldova", code: "md" },
  { name: "Monaco", code: "mc" },
  { name: "Mongolia", code: "mn" },
  { name: "Montenegro", code: "me" },
  { name: "Morocco", code: "ma" },
  { name: "Mozambique", code: "mz" },
  { name: "Myanmar", code: "mm" },
  { name: "Namibia", code: "na" },
  { name: "Nauru", code: "nr" },
  { name: "Nepal", code: "np" },
  { name: "Netherlands", code: "nl" },
  { name: "New Zealand", code: "nz" },
  { name: "Nicaragua", code: "ni" },
  { name: "Niger", code: "ne" },
  { name: "Nigeria", code: "ng" },
  { name: "North Korea", code: "kp" },
  { name: "North Macedonia", code: "mk" },
  { name: "Norway", code: "no" },
  { name: "Oman", code: "om" },
  { name: "Pakistan", code: "pk" },
  { name: "Palau", code: "pw" },
  { name: "Palestine State", code: "ps" },
  { name: "Panama", code: "pa" },
  { name: "Papua New Guinea", code: "pg" },
  { name: "Paraguay", code: "py" },
  { name: "Peru", code: "pe" },
  { name: "Philippines", code: "ph" },
  { name: "Poland", code: "pl" },
  { name: "Portugal", code: "pt" },
  { name: "Qatar", code: "qa" },
  { name: "Romania", code: "ro" },
  { name: "Russia", code: "ru" },
  { name: "Rwanda", code: "rw" },
  { name: "Saint Kitts and Nevis", code: "kn" },
  { name: "Saint Lucia", code: "lc" },
  { name: "Saint Vincent and the Grenadines", code: "vc" },
  { name: "Samoa", code: "ws" },
  { name: "San Marino", code: "sm" },
  { name: "Sao Tome and Principe", code: "st" },
  { name: "Saudi Arabia", code: "sa" },
  { name: "Senegal", code: "sn" },
  { name: "Serbia", code: "rs" },
  { name: "Seychelles", code: "sc" },
  { name: "Sierra Leone", code: "sl" },
  { name: "Singapore", code: "sg" },
  { name: "Slovakia", code: "sk" },
  { name: "Slovenia", code: "si" },
  { name: "Solomon Islands", code: "sb" },
  { name: "Somalia", code: "so" },
  { name: "South Africa", code: "za" },
  { name: "South Korea", code: "kr" },
  { name: "South Sudan", code: "ss" },
  { name: "Spain", code: "es" },
  { name: "Sri Lanka", code: "lk" },
  { name: "Sudan", code: "sd" },
  { name: "Suriname", code: "sr" },
  { name: "Sweden", code: "se" },
  { name: "Switzerland", code: "ch" },
  { name: "Syria", code: "sy" },
  { name: "Tajikistan", code: "tj" },
  { name: "Tanzania", code: "tz" },
  { name: "Thailand", code: "th" },
  { name: "Timor-Leste", code: "tl" },
  { name: "Togo", code: "tg" },
  { name: "Tonga", code: "to" },
  { name: "Trinidad and Tobago", code: "tt" },
  { name: "Tunisia", code: "tn" },
  { name: "Turkey", code: "tr" },
  { name: "Turkmenistan", code: "tm" },
  { name: "Tuvalu", code: "tv" },
  { name: "Uganda", code: "ug" },
  { name: "Ukraine", code: "ua" },
  { name: "United Arab Emirates", code: "ae" },
  { name: "United Kingdom", code: "gb" },
  { name: "United States of America", code: "us" },
  { name: "Uruguay", code: "uy" },
  { name: "Uzbekistan", code: "uz" },
  { name: "Vanuatu", code: "vu" },
  { name: "Venezuela", code: "ve" },
  { name: "Vietnam", code: "vn" },
  { name: "Yemen", code: "ye" },
  { name: "Zambia", code: "zm" },
  { name: "Zimbabwe", code: "zw" }
];

/* The presented goal set depends on the declared age band. The three teen
   categories are a labelled assumption in PRD section 2 with Program
   Operations as owner, not a research finding: no study in the project's
   Informed by list proposes them. The by-band goal_selected distribution is
   what would validate or kill them. */
const goalOptionsByBand = {
  teen: [
    { id: 'english',      title: 'English & Communication', icon: 'record_voice_over', color: 'var(--blue)' },
    { id: 'math_science', title: 'Math & Science',          icon: 'calculate',         color: 'var(--green)' },
    { id: 'life_skills',  title: 'Life skills',             icon: 'self_improvement',  color: 'var(--magenta)' }
  ],
  default: [
    { id: 'data', title: 'Data and analysis', icon: 'bar_chart', color: 'var(--blue)' },
    { id: 'customer', title: 'Customer service', icon: 'support_agent', color: 'var(--magenta)' },
    { id: 'project', title: 'Project management', icon: 'assignment', color: 'var(--green)' },
    { id: 'marketing', title: 'Digital marketing', icon: 'campaign', color: 'var(--red)' },
    { id: 'communication', title: 'Communication', icon: 'forum', color: 'var(--purple)' },
    { id: 'language', title: 'Language skills', icon: 'language', color: 'var(--blue)' }
  ]
};

/* Any band with no entry of its own gets the default set. The adult branch
   parks selectedAgeCategory at null while its sub-ranges are open, and that
   null must resolve to the same set the sub-ranges will, or switching into
   the adult branch would read as a set change and clear the goal twice. */
function goalOptionsFor(band) {
  return goalOptionsByBand[band] || goalOptionsByBand.default;
}

/* The title a stored goal id was PRESENTED as, looked up across every band.
   The handoff carries `goalId` but not the band it was chosen under, and the
   ids are unique across the two sets, so searching both is the honest lookup
   rather than a guess at which set to read.

   IT RETURNS NULL RATHER THAN A FALLBACK. A learner who reached the home
   without a goal — the program path, or a replayed handoff written before this
   field existed — has no goal to show, and the caller hides the row instead of
   printing a plausible one. Naming a goal nobody chose is the fabrication class
   this build exists to remove, and it would be worse here than most: it would
   be putting words in the learner's mouth about their own intent. */
function goalTitleFor(goalId) {
  if (!goalId) return null;
  var bands = Object.keys(goalOptionsByBand);
  for (var b = 0; b < bands.length; b++) {
    var options = goalOptionsByBand[bands[b]];
    for (var i = 0; i < options.length; i++) {
      if (options[i].id === goalId) return options[i].title;
    }
  }
  return null;
}

/* ---- Slice 19: the search starters and the placeholder catalogue ----------

   PLACEHOLDER CONTENT, and every surface that renders it says so. Cycle 7
   ships the SHAPE of a search result list, not a claim that these are the
   courses or that this is the ranking. §14 still excludes a real retrieval or
   recommendation service; what changed on 2026-07-31 is that the prototype may
   now SIMULATE one, provided it is labelled at the point of use. Titles are in
   the same register as main.js's COURSE_MAP — a Program Operations input under
   the §15 open decision, not a curriculum claim made here.

   THE THREE STARTERS ARE A CONSTANT, not a ranking and not personalization.
   They exist because a learner who does not know what to type gets nothing out
   of an empty field, and each one is written to resolve against the set below,
   so activating a starter and searching it always produces results. A starter
   that returned nothing would teach the learner the field is broken. */
const searchStarters = [
  'I want to learn English',
  'I want to get better at math',
  'I want to manage my money'
];

/* Each entry carries its own match keywords rather than being scored by a
   ranker. A ranker is the recommendation model §14 excludes, and relevance a
   reader cannot check by eye is untestable in a prototype: here the reason a
   course matched is readable off this list. `chapters` and `minutes` mirror
   COURSE_MAP so the two never disagree about the same course.

   `topic` IS AN ADJACENCY, NOT A SCORE. It exists because a single-word query
   often has exactly one keyword match, and one card is too thin a result to
   test a result list with. Courses sharing a topic can fill the remainder —
   but they are rendered under their own "related" heading and are NEVER
   counted as matches, because they did not match. The distinction is the whole
   point: a fill-in presented as a match is the fabricated relevance this
   surface is labelled against.

   `cover` IS STOCK PHOTOGRAPHY FROM UNSPLASH, and the surface says so wherever
   it renders one — the card carries a visible "Placeholder cover" tag. These
   are not course covers; there is no curriculum for a cover to be *of* while
   the goal-to-course map is an open §15 decision. Each URL was loaded and each
   image looked at before it was assigned here, so the subject actually matches
   the course rather than being inferred from a photo id.

   TWO COSTS, both recorded rather than discovered later. (1) These are
   EXTERNAL requests, on the same footing as the existing web-font and logo
   links in this prototype — but a published Artifact's CSP blocks external
   hosts, so covers will not render there. That degrades to the tinted gradient
   and glyph behind them rather than to a broken image, which is why the
   fallback is a real design and not a nicety. (2) A shipped version needs its
   own licensed art; nothing here is a licence decision. */
const searchCatalogue = [
  { id: 'eng-1',  title: 'Everyday English Communication', icon: 'record_voice_over', color: 'var(--blue)',
    chapters: 5, minutes: 6, topic: 'communication',
    keywords: ['english', 'inggris', 'speak', 'speaking', 'conversation', 'language', 'grammar', 'vocabulary'],
    /* books, an apple and alphabet blocks */
    cover: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=1000&q=60' },
  { id: 'msci-1', title: 'Math and Science Foundations',   icon: 'calculate',         color: 'var(--green)',
    chapters: 6, minutes: 8, topic: 'numeracy',
    keywords: ['math', 'maths', 'mathematics', 'matematika', 'science', 'algebra', 'fraction', 'number', 'formula'],
    /* a board of algebra equations */
    cover: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?auto=format&fit=crop&w=1000&q=60' },
  { id: 'life-1', title: 'Everyday Life Skills',           icon: 'self_improvement',  color: 'var(--magenta)',
    chapters: 4, minutes: 7, topic: 'life',
    keywords: ['life', 'money', 'budget', 'saving', 'save', 'finance', 'financial', 'uang', 'payslip', 'spending'],
    /* tax forms, a calculator and a phone */
    cover: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=1000&q=60' },
  { id: 'dig-1',  title: 'Digital Safety and Wellbeing',   icon: 'shield',            color: 'var(--purple)',
    chapters: 4, minutes: 5, topic: 'life',
    keywords: ['safety', 'safe', 'online', 'scam', 'password', 'privacy', 'wellbeing', 'digital'],
    /* a hand touching a screen */
    cover: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1000&q=60' },
  { id: 'data-1', title: 'Data and Analysis Foundations',  icon: 'bar_chart',         color: 'var(--blue)',
    chapters: 5, minutes: 8, topic: 'numeracy',
    keywords: ['data', 'analysis', 'analyse', 'analyze', 'chart', 'graph', 'statistics', 'spreadsheet', 'excel'],
    /* a laptop showing an analytics dashboard */
    cover: 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1000&q=60' },
  { id: 'comm-1', title: 'Workplace Communication',        icon: 'forum',             color: 'var(--purple)',
    chapters: 4, minutes: null, topic: 'communication',
    keywords: ['communication', 'communicate', 'email', 'presentation', 'meeting', 'workplace', 'colleague'],
    /* three colleagues talking over laptops */
    cover: 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=1000&q=60' },
  { id: 'cust-1', title: 'Customer Service Essentials',    icon: 'support_agent',     color: 'var(--magenta)',
    chapters: 4, minutes: 10, topic: 'communication',
    keywords: ['customer', 'service', 'support', 'retail', 'shop', 'sales', 'complaint'],
    /* a conversation across a desk */
    cover: 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?auto=format&fit=crop&w=1000&q=60' },
  { id: 'proj-1', title: 'Project Management Basics',      icon: 'assignment',        color: 'var(--green)',
    chapters: 6, minutes: 7, topic: 'work',
    keywords: ['project', 'manager', 'planning', 'deadline', 'team', 'task', 'organise', 'organize'],
    /* hands planning over notes and laptops */
    cover: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=1000&q=60' },
  { id: 'mkt-1',  title: 'Digital Marketing Fundamentals', icon: 'campaign',          color: 'var(--red)',
    chapters: 5, minutes: 9, topic: 'work',
    keywords: ['marketing', 'advertising', 'audience', 'brand', 'promote', 'campaign', 'social'],
    /* a team at a wall of sticky notes */
    cover: 'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1000&q=60' }
];

/* Words carrying no topic. Stripped before matching so "I want to learn
   English" does not match every course that happens to use the word "learn" in
   a keyword. Kept short on purpose: an aggressive list silently swallows real
   query terms, which is harder to notice than a stray match. */
const searchStopWords = [
  'i', 'a', 'an', 'the', 'to', 'of', 'in', 'on', 'at', 'my', 'me', 'is', 'it',
  'want', 'wanna', 'need', 'like', 'learn', 'learning', 'study', 'studying',
  'how', 'can', 'do', 'for', 'and', 'with', 'about', 'get', 'better', 'good',
  'more', 'some', 'help', 'please', 'course', 'courses', 'class', 'be', 'become'
];

/* A contains-match over declared keywords, ordered by how many query terms hit.
   NOT a relevance model — the score is a count, and it reaches the screen as a
   count of matching courses rather than dressed up as a ranking.

   Returns TWO lists, and keeping them separate is the honesty mechanism:
     `matches` — courses a query term actually hit. Capped at three.
     `related` — courses sharing a match's topic that did NOT hit. They fill the
                 list out to three and render under their own heading.
   An empty query returns two empty lists. Substituting a default set when
   nothing matched would be the fabrication this document is written against;
   the caller says so instead. */
function searchCourses(query) {
  var q = String(query || '').toLowerCase();
  var terms = q.split(/[^a-z0-9]+/).filter(function (w) {
    return w.length > 1 && searchStopWords.indexOf(w) === -1;
  });
  if (!terms.length) return { matches: [], related: [] };

  var matches = searchCatalogue.map(function (course) {
    var haystack = (course.title.toLowerCase() + ' ' + course.keywords.join(' '));
    var hits = terms.filter(function (t) { return haystack.indexOf(t) !== -1; }).length;
    return { course: course, hits: hits };
  }).filter(function (row) {
    return row.hits > 0;
  }).sort(function (a, b) {
    return b.hits - a.hits;
  }).slice(0, 3).map(function (row) {
    return row.course;
  });

  /* Nothing matched means nothing is related either. Topic adjacency hangs off
     a match, so with no match there is no anchor and offering the topic set
     anyway would be the substitute-set behaviour ruled out above. */
  if (!matches.length) return { matches: [], related: [] };

  var topics = matches.map(function (c) { return c.topic; });
  var chosen = matches.map(function (c) { return c.id; });
  var related = searchCatalogue.filter(function (course) {
    return chosen.indexOf(course.id) === -1 && topics.indexOf(course.topic) !== -1;
  }).slice(0, Math.max(0, 3 - matches.length));

  return { matches: matches, related: related };
}

window.allCountries = allCountries;
window.goalOptionsByBand = goalOptionsByBand;
window.goalOptionsFor = goalOptionsFor;
window.goalTitleFor = goalTitleFor;
window.searchStarters = searchStarters;
window.searchCatalogue = searchCatalogue;
window.searchCourses = searchCourses;
