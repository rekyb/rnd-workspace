const appState = {
  entryPath: 'organic',
  selectedGoal: null,
  selectedAgeCategory: null,
  selectedGender: null,
  selectedCountry: null,
  historyStack: [],
  isNameValid: false
};

function escapeHTML(str) {
  if (!str) return '';
  return str.replace(/[&<>'"]/g, tag => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    "'": '&#39;',
    '"': '&quot;'
  }[tag] || tag));
}

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('age-btn-adult-55')?.addEventListener('click', function() { selectAgeOption(this, 'adult_55_plus', true); });
  document.getElementById('age-btn-young-adult')?.addEventListener('click', function() { selectAgeOption(this, 'young_adult'); });
  document.getElementById('start-lesson-btn')?.addEventListener('click', () => finishOnboarding());
  document.getElementById('lang-en')?.addEventListener('click', () => selectLang('en', 'English', 'https://flagcdn.com/w20/us.png'));
  document.getElementById('global-continue-btn')?.addEventListener('click', handleGlobalContinue);
  document.getElementById('bottom-start-organic-btn')?.addEventListener('click', startOrganic);
  document.getElementById('age-btn-adult')?.addEventListener('click', function() { selectAgeOption(this, 'adult'); });
  document.getElementById('hero-start-program-btn')?.addEventListener('click', startProgram);
  document.getElementById('lang-id')?.addEventListener('click', () => selectLang('id', 'Bahasa Indonesia', 'https://flagcdn.com/w20/id.png'));
  document.getElementById('save-wall-signin-btn')?.addEventListener('click', openSignInModal);
  document.getElementById('onboarding-back-btn')?.addEventListener('click', goBack);
  document.getElementById('header-signup-btn')?.addEventListener('click', startOrganic);
  document.getElementById('age-btn-adult-25')?.addEventListener('click', function() { selectAgeOption(this, 'adult_25_34', true); });
  document.getElementById('join_btn')?.addEventListener('click', submitCode);
  document.getElementById('age-btn-adult-35')?.addEventListener('click', function() { selectAgeOption(this, 'adult_35_44', true); });
  document.getElementById('hero-start-organic-btn')?.addEventListener('click', startOrganic);
  document.getElementById('age-btn-adult-45')?.addEventListener('click', function() { selectAgeOption(this, 'adult_45_54', true); });
  document.getElementById('sso-btn-google')?.addEventListener('click', () => finishOnboarding());
  document.getElementById('sso-btn-facebook')?.addEventListener('click', () => finishOnboarding());
  document.getElementById('age-btn-teen')?.addEventListener('click', function() { selectAgeOption(this, 'teen'); });
  document.getElementById('gender-btn-female')?.addEventListener('click', function() { selectGender(this, 'female'); });
  document.getElementById('gender-btn-male')?.addEventListener('click', function() { selectGender(this, 'male'); });
  document.getElementById('gender-btn-prefer')?.addEventListener('click', function() { selectGender(this, 'prefer_not_to_say'); });
  document.getElementById('header-signin-btn')?.addEventListener('click', openSignInModal);
  document.getElementById('logo-link')?.addEventListener('click', (e) => { e.preventDefault(); goTo('landing'); });
  document.getElementById('close-signin-modal-btn')?.addEventListener('click', () => closeModal('sign_in_modal'));
  document.getElementById('signin-btn-google')?.addEventListener('click', () => { finishOnboarding(); closeModal('sign_in_modal'); });
  document.getElementById('lang-select-selected')?.addEventListener('click', toggleSelect);
  document.getElementById('close-code-modal-btn')?.addEventListener('click', () => closeModal('code_entry_modal'));
  document.getElementById('signin-modal-signup-btn')?.addEventListener('click', () => { closeModal('sign_in_modal'); startOrganic(); });
  document.getElementById('signin-btn-facebook')?.addEventListener('click', () => { finishOnboarding(); closeModal('sign_in_modal'); });

  document.getElementById('name_input')?.addEventListener('input', validateName);
  document.getElementById('country_search')?.addEventListener('input', handleCountryInput);
  document.getElementById('country_search')?.addEventListener('keydown', handleCountryKeydown);

  document.getElementById('save_email_input')?.addEventListener('input', validateSaveGate);
  document.getElementById('save_password_input')?.addEventListener('input', validateSaveGate);
  document.getElementById('save_create_btn')?.addEventListener('click', () => finishOnboarding());

  document.getElementById('login_email_input')?.addEventListener('input', validateLoginModal);
  document.getElementById('login_password_input')?.addEventListener('input', validateLoginModal);
  document.getElementById('login_submit_btn')?.addEventListener('click', () => { finishOnboarding(); closeModal('sign_in_modal'); });

  function validateSaveGate() {
    const email = document.getElementById('save_email_input')?.value || '';
    const pwd = document.getElementById('save_password_input')?.value || '';
    const btn = document.getElementById('save_create_btn');
    if (!btn) return;
    
    const isValidEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    // PRD 7.3: production password policy is at least 8 characters. The UI only
    // guides; the server remains the source of truth.
    const isValidPwd = pwd.length >= 8;

    btn.disabled = !(isValidEmail && isValidPwd);
  }

  function validateLoginModal() {
    const email = document.getElementById('login_email_input')?.value || '';
    const pwd = document.getElementById('login_password_input')?.value || '';
    const btn = document.getElementById('login_submit_btn');
    if (!btn) return;
    
    const isValidEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    // Deliberately lower than the 8-character creation policy: an existing
    // account may predate it, and login must not lock out valid credentials.
    const isValidPwd = pwd.length >= 6;

    btn.disabled = !(isValidEmail && isValidPwd);
  }



  // Code input UX auto-advance
  const inputs = document.querySelectorAll('.code-digit');
  const joinBtn = document.getElementById('join_btn');

  function checkCodeLength() {
    let code = '';
    inputs.forEach(i => code += i.value);
    if (joinBtn) joinBtn.disabled = code.length < 6;
  }

  inputs.forEach((input, index) => {
    input.addEventListener('input', (e) => {
      // Add pulse animation
      input.classList.remove('pulse');
      void input.offsetWidth; // trigger reflow
      input.classList.add('pulse');
      input.addEventListener('animationend', () => input.classList.remove('pulse'), {once: true});
      
      if (e.target.value.length === 1 && index < inputs.length - 1) {
        inputs[index + 1].focus();
      }
      checkCodeLength();
    });
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Backspace' && e.target.value.length === 0 && index > 0) {
        inputs[index - 1].focus();
      }
    });
  });

  renderGoalCards();
});

const progressMap = {
  'landing': 0,
  'name_gate': 10,
  'country_gate': 28,
  'age_gate': 46,
  'gender_gate': 64,
  'goal_intake': 82,
  'save_wall': 100,
};

    function updateHeaders(screenId) {
      if (screenId === 'landing' || screenId === 'sign_in') {
        document.body.classList.remove('is-onboarding');
        document.getElementById('global-header').style.display = 'flex';
        document.getElementById('onboarding-header').style.display = 'none';
        document.getElementById('onboarding-footer').style.display = 'none';
      } else {
        document.body.classList.add('is-onboarding');
        document.getElementById('global-header').style.display = 'none';
        document.getElementById('onboarding-header').style.display = 'flex';
        let prog = progressMap[screenId] || 0;
        if (appState.entryPath === 'program') {
            const programProgressMap = {
                'assigned_content': 17,
                'name_gate': 33,
                'country_gate': 50,
                'age_gate': 67,
                'gender_gate': 83,
                'save_wall': 100,
            };
            prog = programProgressMap[screenId] || 0;
        }
        document.getElementById('progress-bar').style.width = prog + '%';
        
        const footer = document.getElementById('onboarding-footer');
        const btn = document.getElementById('global-continue-btn');
        
        if (['name_gate', 'country_gate', 'age_gate', 'gender_gate', 'goal_intake', 'assigned_content'].includes(screenId)) {
          footer.style.display = 'flex';
          document.body.classList.add('has-footer');
          if (screenId === 'name_gate') {
            btn.disabled = !appState.isNameValid;
            btn.innerText = 'Continue';
          } else if (screenId === 'country_gate') {
            btn.disabled = !appState.selectedCountry;
            btn.innerText = 'Continue';
          } else if (screenId === 'age_gate') {
            btn.disabled = !appState.selectedAgeCategory;
            btn.innerText = 'Continue';
          } else if (screenId === 'gender_gate') {
            btn.disabled = !appState.selectedGender;
            btn.innerText = 'Continue';
          } else if (screenId === 'goal_intake') {
            btn.disabled = !appState.selectedGoal;
            btn.innerText = 'Continue';
          } else if (screenId === 'assigned_content') {
            btn.disabled = false;
            btn.innerText = 'Continue';
          }
        } else {
          footer.style.display = 'none';
          document.body.classList.remove('has-footer');
        }
      }
    }

    function handleGlobalContinue() {
      const activeCard = document.querySelector('.card.active').id;
      if (activeCard === 'name_gate') {
        const userName = escapeHTML(document.getElementById('name_input').value.trim());
        document.getElementById('country_gate_title').innerHTML = `<span style="font-size: 1rem; font-weight: 500; color: var(--sub); display: block; margin-bottom: 8px;">Hi, <span style="color: var(--purple); font-weight: 700;">${userName}</span>!</span>Where are you from?`;
        goTo('country_gate');
      } else if (activeCard === 'country_gate') {
        goTo('age_gate');
      } else if (activeCard === 'age_gate') {
        continueFromAge();
      } else if (activeCard === 'gender_gate') {
        continueFromGender();
      } else if (activeCard === 'goal_intake') {
        continueFromGoal();
      } else if (activeCard === 'assigned_content') {
        document.getElementById('name_gate_title').innerHTML = '<span style="font-size: 16px; font-weight: 500; color: var(--sub); display: block; margin-bottom: 8px;">Welcome to <span style="color: var(--purple); font-weight: 700;">Digital Heroes</span>!</span>What is your name?';
        goTo('name_gate');
      }
    }

    function hideAll() {
      const cards = document.querySelectorAll('.card');
      cards.forEach(c => c.classList.remove('active'));
    }

    function goTo(screenId, isBack = false) {
      const current = document.querySelector('.card.active');
      if (!isBack && current && current.id !== screenId && current.id !== 'landing') {
        if (appState.historyStack.length === 0 || appState.historyStack[appState.historyStack.length - 1] !== current.id) {
          appState.historyStack.push(current.id);
        }
      } else if (screenId === 'landing') {
        appState.historyStack = [];
      }

      hideAll();
      // Reset errors when navigating
      document.getElementById('code_error').style.display = 'none';
      document.getElementById('code-group').style.animation = 'none';
      
      document.getElementById(screenId).classList.add('active');
      window.scrollTo(0, 0);
      updateHeaders(screenId);
    }

    function goBack() {
      if (appState.historyStack.length > 0) {
        const prev = appState.historyStack.pop();
        goTo(prev, true);
      } else {
        goTo('landing');
      }
    }

    function startOrganic() {
      appState.entryPath = 'organic';
      document.getElementById('name_gate_title').innerHTML = '<span style="font-size: 16px; font-weight: 500; color: var(--sub); display: block; margin-bottom: 8px;">Welcome to <strong style="color: var(--purple);">Solve Education!</strong></span>What is your name?';
      goTo('name_gate');
    }

    function startProgram() {
      appState.entryPath = 'program';
      openModal('code_entry_modal', '.code-digit');
    }

    function openSignInModal() {
      openModal('sign_in_modal', '#login_email_input');
    }

    // --- Modal focus management -------------------------------------------
    // The modals live inside <main> alongside the screen cards, so the
    // background is made inert per-element rather than on one container.

    const MODAL_FOCUSABLE = 'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])';

    let modalReturnFocus = null;

    function backgroundElements() {
      return [
        document.getElementById('global-header'),
        document.getElementById('onboarding-header'),
        document.getElementById('onboarding-footer'),
        ...document.querySelectorAll('.card')
      ].filter(Boolean);
    }

    function openModal(id, initialFocusSelector) {
      const modal = document.getElementById(id);
      if (!modal) return;

      modalReturnFocus = document.activeElement;
      modal.classList.add('show');
      backgroundElements().forEach(el => el.setAttribute('inert', ''));

      const target = (initialFocusSelector && modal.querySelector(initialFocusSelector))
        || modal.querySelector(MODAL_FOCUSABLE)
        || modal.querySelector('.modal-content');
      target?.focus();
    }

    function closeModal(id) {
      const modal = document.getElementById(id);
      if (!modal) return;

      modal.classList.remove('show');
      if (!document.querySelector('.modal-overlay.show')) {
        backgroundElements().forEach(el => el.removeAttribute('inert'));
      }

      const returnTo = modalReturnFocus;
      modalReturnFocus = null;
      // Only restore focus when the trigger is still on screen. Navigating away
      // (login -> learning_home) legitimately removes it, and focusing a hidden
      // element would drop focus into nowhere.
      if (returnTo && returnTo.isConnected && returnTo.offsetParent !== null) {
        returnTo.focus();
      }
    }

    function trapModalTab(event) {
      const modal = document.querySelector('.modal-overlay.show');
      if (!modal) return;

      const focusables = Array.from(modal.querySelectorAll(MODAL_FOCUSABLE))
        .filter(el => el.offsetParent !== null);
      if (focusables.length === 0) return;

      const first = focusables[0];
      const last = focusables[focusables.length - 1];

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener('keydown', event => {
      if (event.key === 'Escape') {
        const modal = document.querySelector('.modal-overlay.show');
        if (modal) closeModal(modal.id);
      } else if (event.key === 'Tab') {
        trapModalTab(event);
      }
    });

    function submitCode() {
      const inputs = document.querySelectorAll('.code-digit');
      let code = '';
      inputs.forEach(i => code += i.value);
      
      if (code === '123456') {
        document.getElementById('code_error').style.display = 'none';
        closeModal('code_entry_modal');
        goTo('assigned_content');
      } else if (code === '111111') {
        const errorEl = document.getElementById('code_error');
        errorEl.innerHTML = '<span class="material-symbols-rounded" style="vertical-align: middle; font-size: 18px;">error</span> This program code has expired.';
        errorEl.style.display = 'block';
        const group = document.getElementById('code-group');
        group.style.animation = 'none';
        void group.offsetWidth; // trigger reflow
        group.style.animation = 'obShake 0.4s';
      } else {
        const errorEl = document.getElementById('code_error');
        errorEl.innerHTML = '<span class="material-symbols-rounded" style="vertical-align: middle; font-size: 18px;">error</span> Invalid code entered. Please try again.';
        errorEl.style.display = 'block';
        const group = document.getElementById('code-group');
        group.style.animation = 'none';
        void group.offsetWidth; // trigger reflow
        group.style.animation = 'obShake 0.4s';
      }
    }

    function showAdultOptions() {
      document.getElementById('age-adult-options').style.display = 'flex';
      setTimeout(() => {
        document.getElementById('age-adult-options').scrollIntoView({ behavior: 'smooth', block: 'end' });
      }, 50);
    }

    function hideAdultOptions() {
      document.getElementById('age-adult-options').style.display = 'none';
    }


    /* The one writer of selectedAgeCategory. A band whose option set differs
       from the outgoing one invalidates any goal already chosen, because that
       goal is not in the set the learner is about to see. Clearing it here is
       enough to re-disable Continue: updateHeaders derives the disabled state
       from selectedGoal, so there is no second code path to keep in step.
       Compared by resolved set, not by raw category, so opening the adult
       branch (which parks the category at null) does not read as a change. */
    function setAgeCategory(category) {
      if (goalOptionsFor(appState.selectedAgeCategory) !== goalOptionsFor(category)) {
        appState.selectedGoal = null;
      }
      appState.selectedAgeCategory = category;
    }

    function selectAgeOption(element, category, isAdultSubOption = false) {
      if (isAdultSubOption) {
        const peers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
        peers.forEach(p => p.classList.remove('selected'));
        setAgeCategory(category);
        document.getElementById('global-continue-btn').disabled = false;
      } else {
        const peers = document.getElementById('age-primary-options').querySelectorAll('.option-card');
        peers.forEach(p => p.classList.remove('selected'));

        if (category === 'adult') {
          showAdultOptions();
          setAgeCategory(null);
          document.getElementById('global-continue-btn').disabled = true;
          const subPeers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
          subPeers.forEach(p => p.classList.remove('selected'));
        } else {
          hideAdultOptions();
          setAgeCategory(category);
          document.getElementById('global-continue-btn').disabled = false;
        }
      }
      element.classList.add('selected');
    }

    function continueFromAge() {
      if (!appState.selectedAgeCategory) return;
      goTo('gender_gate');
    }

    function continueFromGender() {
      if (!appState.selectedGender) return;
      if (appState.entryPath === 'organic') {
        goTo('goal_intake');
      } else {
        goTo('save_wall');
        populateProfileSummary();
      }
    }

    function selectGender(element, gender) {
      const peers = document.getElementById('gender_options').querySelectorAll('.gender-card');
      peers.forEach(p => {
        p.classList.remove('selected');
        p.setAttribute('aria-pressed', 'false');
      });
      appState.selectedGender = gender;
      element.classList.add('selected');
      element.setAttribute('aria-pressed', 'true');
      document.getElementById('global-continue-btn').disabled = false;
    }



    function renderGoalCards() {
      const grid = document.getElementById('goal_grid');
      if (!grid) return;

      grid.innerHTML = '';
      goalOptionsFor(appState.selectedAgeCategory).forEach(goal => {
        const card = document.createElement('button');
        const isSelected = appState.selectedGoal === goal.id;
        card.type = 'button';
        card.className = `choice-card${isSelected ? ' selected' : ''}`;
        card.setAttribute('aria-pressed', isSelected.toString());
        card.innerHTML = `
          <span class="material-symbols-rounded choice-card-icon" aria-hidden="true" style="color: ${goal.color};">${goal.icon}</span>
          <span class="choice-card-title">${goal.title}</span>
        `;
        card.addEventListener('click', () => selectGoal(goal.id));
        grid.appendChild(card);
      });
    }

    function selectGoal(goalId) {
      appState.selectedGoal = goalId;
      renderGoalCards();
      document.getElementById('global-continue-btn').disabled = false;
    }

    function continueFromGoal() {
      if (!appState.selectedGoal) return;
      goTo('save_wall');
      populateProfileSummary();
    }

    let snackbarTimeout;
    function showSnackbar(msg) {
      const sb = document.getElementById('snackbar');
      document.getElementById('snackbar_text').innerText = msg;
      sb.classList.add('show');
      
      clearTimeout(snackbarTimeout);
      snackbarTimeout = setTimeout(() => {
        sb.classList.remove('show');
      }, 4000);
    }
    
    function toggleSelect(e) {
      e.stopPropagation();
      document.getElementById('lang-options').classList.toggle('select-hide');
    }

    
    function selectLang(val, name, imgSrc) {
      document.getElementById('selected-lang').innerText = name;
      document.getElementById('selected-flag').src = imgSrc;
      document.getElementById('lang-options').classList.add('select-hide');
      
      const obLang = document.getElementById('selected-lang-ob');
      const obFlag = document.getElementById('selected-flag-ob');
      if (obLang) obLang.innerText = name;
      if (obFlag) obFlag.src = imgSrc;
      
      showSnackbar('Language changed to ' + name);
    }
    

    
    document.addEventListener('click', function(e) {
      const langDropdown = document.getElementById('lang-options');
      if (langDropdown && !langDropdown.classList.contains('select-hide') && !e.target.closest('.custom-select')) {
        langDropdown.classList.add('select-hide');
      }
      
      const countryDropdown = document.getElementById('country_dropdown');
      if (countryDropdown && !countryDropdown.classList.contains('select-hide') && !e.target.closest('#country_combobox')) {
        closeCountryDropdown();
      }
    });



    // Scroll listener for sticky header and Sign Up button
    window.addEventListener('scroll', () => {
      const header = document.querySelector('.app-header');
      const signupBtn = document.getElementById('header-signup-btn');
      const hero = document.getElementById('hero-section');
      
      let threshold = 500;
      if (hero) {
        // threshold is the bottom of the hero section, offset slightly by header height
        threshold = hero.offsetHeight - 80; 
      }
      
      // Header shadow appears immediately on scroll
      if (window.scrollY > 10) {
        header.classList.add('scrolled');
      } else {
        header.classList.remove('scrolled');
      }

      // Sign Up button only appears after scrolling past hero section
      if (window.scrollY > threshold) {
        signupBtn.style.display = 'block';
      } else {
        signupBtn.style.display = 'none';
      }
    });

    // New Onboarding Logic

    function validateName() {
      const input = document.getElementById('name_input');
      const val = input.value.trim();
      const regex = /^[a-zA-Z0-9\/\.\-'\s]{3,50}$/;
      appState.isNameValid = regex.test(val);
      
      const errorEl = document.getElementById('name_error');
      if (val.length > 0 && !appState.isNameValid) {
        errorEl.style.display = 'block';
      } else {
        errorEl.style.display = 'none';
      }
      updateHeaders('name_gate');
    }

    let activeCountryIndex = -1;
    let filteredCountries = [];
    allCountries.sort((a, b) => a.name.localeCompare(b.name));

    // Optional callback for external usage
    window.onCountrySelect = window.onCountrySelect || function(country) {
      console.log('Selected country:', country.name, country.code.toUpperCase(), country.dialCode || '');
    };

    function handleCountryInput() {
      const input = document.getElementById('country_search');
      const query = input.value.trim();
      input.removeAttribute('aria-activedescendant');
      appState.selectedCountry = null;
      document.getElementById('country_select_flag').style.display = 'none';
      document.getElementById('global-continue-btn').disabled = true;
      activeCountryIndex = -1;

      if (!query) {
        closeCountryDropdown();
        document.getElementById('country_list').innerHTML = '';
        document.getElementById('country_status').textContent = '';
        document.getElementById('country_status').style.display = 'none';
        return;
      }

      renderCountryList(query);
      const dropdown = document.getElementById('country_dropdown');
      dropdown.classList.remove('select-hide');
      input.setAttribute('aria-expanded', 'true');
    }

    function renderCountryList(filterText) {
      const list = document.getElementById('country_list');
      const status = document.getElementById('country_status');
      const query = filterText.toLowerCase();
      
      // Filter by name or ISO code
      filteredCountries = allCountries.filter(country =>
        country.name.toLowerCase().includes(query) || country.code.toLowerCase().includes(query)
      );
      list.innerHTML = '';
      status.textContent = '';
      status.style.display = 'none';

      if (filteredCountries.length === 0) {
        status.textContent = 'No countries found';
        status.style.display = 'block';
        return;
      }

      // Helper to highlight matching text. The query is escaped first so a
      // regex metacharacter typed by the learner cannot throw a SyntaxError.
      const highlight = (text, q) => {
        if (!q) return text;
        const regex = new RegExp(`(${q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')})`, 'gi');
        return text.replace(regex, '<strong>$1</strong>');
      };

      filteredCountries.forEach((country, index) => {
        const option = document.createElement('div');
        option.className = 'country-option';
        option.id = `country-option-${index}`;
        option.setAttribute('role', 'option');
        option.setAttribute('aria-selected', (index === activeCountryIndex).toString());
        
        const highlightedName = highlight(country.name, query);
        const isoCode = country.code.toUpperCase();
        
        option.innerHTML = `
          <img class="flag-icon" src="https://flagcdn.com/w20/${country.code}.png" alt="" onerror="this.style.visibility='hidden'" style="flex-shrink: 0;">
          <span style="flex-grow: 1;">${highlightedName}</span>
          <span style="color: var(--sub); font-size: 14px; font-weight: bold; flex-shrink: 0;">${isoCode}</span>
        `;
        
        option.addEventListener('mousedown', event => {
          event.preventDefault();
          selectCountry(country);
        });
        list.appendChild(option);
      });
    }

    function selectCountry(country) {
      appState.selectedCountry = country;
      const input = document.getElementById('country_search');
      const flag = document.getElementById('country_select_flag');
      input.value = country.name;
      flag.src = `https://flagcdn.com/w20/${country.code}.png`;
      flag.alt = '';
      flag.style.display = 'block';
      document.getElementById('global-continue-btn').disabled = false;
      closeCountryDropdown();
      
      // Trigger external callback
      if (typeof window.onCountrySelect === 'function') {
        window.onCountrySelect({
          name: country.name,
          isoCode: country.code.toUpperCase(),
          dialCode: country.dialCode || null
        });
      }
    }

    function closeCountryDropdown() {
      const input = document.getElementById('country_search');
      document.getElementById('country_dropdown').classList.add('select-hide');
      input.setAttribute('aria-expanded', 'false');
      input.removeAttribute('aria-activedescendant');
      activeCountryIndex = -1;
    }

    function handleCountryKeydown(event) {
      if (document.getElementById('country_dropdown').classList.contains('select-hide')) return;
      if (event.key === 'Escape') {
        closeCountryDropdown();
        return;
      }
      if (filteredCountries.length === 0) return;

      if (event.key === 'ArrowDown') {
        event.preventDefault();
        activeCountryIndex = Math.min(activeCountryIndex + 1, filteredCountries.length - 1);
      } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        activeCountryIndex = Math.max(activeCountryIndex - 1, 0);
      } else if (event.key === 'Enter' && activeCountryIndex >= 0) {
        event.preventDefault();
        selectCountry(filteredCountries[activeCountryIndex]);
        return;
      } else {
        return;
      }

      renderCountryList(document.getElementById('country_search').value.trim());
      const optionId = `country-option-${activeCountryIndex}`;
      document.getElementById('country_search').setAttribute('aria-activedescendant', optionId);
      document.getElementById(optionId)?.scrollIntoView({ block: 'nearest' });
    }
  
  
  /* ---- Journey handoff -------------------------------------------------
     The funnel ends here. Everything the Learning Home needs is written once,
     at finalization, and read back on the next page. initialCourseId is
     resolved and STORED now rather than recomputed at render time, so
     changing the course map later cannot silently change this learner's
     first action (PRD Slice 13). */
  /* firstSkill and firstSkillMinutes are what let the primary action name one
     specific, time-bounded thing instead of offering a course (PRD Slice 13,
     from layout F6). firstSkillMinutes is deliberately nullable, and
     'communication' carries null: a duration the content service does not have
     is omitted, never rounded or defaulted. That is the same rule as an
     unmapped goal, applied to time instead of to content, and it is reachable
     here through a real data path rather than a debug switch. */
  const COURSE_MAP = {
    'data':          { id: 'data-1',    title: 'Data and Analysis Foundations',  skills: 5, firstSkill: 'Read a bar chart',            firstSkillMinutes: 8 },
    'customer':      { id: 'cust-1',    title: 'Customer Service Essentials',    skills: 4, firstSkill: 'Handle an angry customer',    firstSkillMinutes: 10 },
    'project':       { id: 'proj-1',    title: 'Project Management Basics',      skills: 6, firstSkill: 'Write a task brief',          firstSkillMinutes: 7 },
    'marketing':     { id: 'mkt-1',     title: 'Digital Marketing Fundamentals', skills: 5, firstSkill: 'Choose an audience',          firstSkillMinutes: 9 },
    'communication': { id: 'comm-1',    title: 'Workplace Communication',        skills: 4, firstSkill: 'Ask a clarifying question',   firstSkillMinutes: null },
    /* The teen set. Placeholder titles in the same register as the five above:
       the real goal-to-course mapping is a Program Operations input under the
       PRD section 15 open decision, not a curriculum claim made here. */
    'english':       { id: 'eng-1',     title: 'Everyday English Communication', skills: 5, firstSkill: 'Introduce yourself',          firstSkillMinutes: 6 },
    'math_science':  { id: 'msci-1',    title: 'Math and Science Foundations',   skills: 6, firstSkill: 'Read a data table',           firstSkillMinutes: 8 },
    'life_skills':   { id: 'life-1',    title: 'Everyday Life Skills',           skills: 4, firstSkill: 'Plan a weekly budget',        firstSkillMinutes: 7 }
    /* 'language' is deliberately absent: it is the unmapped case, and the home
       must show an empty state rather than substitute a default course. */
  };

  /* The enrolment's assigned tasks. Stands in for the program service payload,
     and is written onto the handoff at finalization so the Learning Home reads
     a denominator it was given rather than one it declared. */
  const PROGRAM_TASKS = [
    { id: 't1', title: 'Complete your registration', done: true },
    { id: 't2', title: 'Start your first course' },
    { id: 't3', title: 'Finish three skills' },
    { id: 't4', title: 'Complete your program' }
  ];

  function finishOnboarding() {
    const name = (document.getElementById('name_input')?.value || '').trim() || 'Learner';
    const goal = appState.selectedGoal || null;
    const mapped = goal ? COURSE_MAP[goal] : null;
    const isProgram = appState.entryPath === 'program';

    const handoff = {
      displayName: name,
      entryPath: isProgram ? 'program' : 'organic',
      goalId: goal,
      /* null means unmapped. It never means "use a default". */
      initialCourseId: mapped ? mapped.id : null,
      courseTitle: mapped ? mapped.title : null,
      skillTotal: mapped ? mapped.skills : null,
      /* The specific first item and its cost. Null minutes means the estimate
         is unknown; the home omits the line rather than inventing one. */
      firstSkillTitle: mapped ? mapped.firstSkill : null,
      firstSkillMinutes: mapped ? mapped.firstSkillMinutes : null,
      programName: isProgram ? 'Digital Heroes' : null,
      /* The assigned-task payload and its denominator are written here, from
         the enrolment, exactly as initialCourseId is. They used to be a
         constant inside the Learning Home view, which made the denominator a
         client-side literal that Slice 12's zero-state criterion forbids. */
      programTasks: isProgram ? PROGRAM_TASKS.slice() : null,
      taskTotal: isProgram ? PROGRAM_TASKS.length : null,
      skillsDone: 0,
      tasksDone: 0,
      firstActionAt: null
    };
    try { sessionStorage.setItem('se_handoff', JSON.stringify(handoff)); } catch (e) {}
    window.location.href = 'home.html';
  }

  function populateProfileSummary() {
      // Handle program flow specific copy and UI
      if (typeof appState.entryPath !== 'undefined' && appState.entryPath === 'program') {
          const uName = escapeHTML(document.getElementById('name_input').value.trim() || 'Learner');
          document.getElementById('save_wall_title').innerHTML = `One more step, <span style="color: var(--purple); font-weight: 700;">${uName}</span>!`;
          document.getElementById('save_wall_subtitle').innerHTML = 'Create an account to finalize your registration for <span style="color: var(--purple); font-weight: 700;">Digital Heroes</span>.';
          
          const divider = document.getElementById('save_wall_divider');
          if (divider) divider.style.display = 'none';
          
      } else {
          const uName = escapeHTML(document.getElementById('name_input').value.trim() || 'Learner');
          document.getElementById('save_wall_title').innerHTML = `One more step, <span style="color: var(--purple); font-weight: 700;">${uName}</span>!`;
          document.getElementById('save_wall_subtitle').innerHTML = 'Create your account to save your personalized profile and start learning.';
          
          const divider = document.getElementById('save_wall_divider');
          if (divider) divider.style.display = 'none';
          
          // Increase image size
          const saveImg = document.querySelector('#save_wall img');
          if (saveImg) {
            saveImg.style.transform = 'scale(1.25)';
            saveImg.style.transformOrigin = 'center';
          }
      }
    }
    
  
