const appState = {
  entryPath: 'organic',
  selectedGoal: null,
  selectedAgeCategory: null,
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
  document.getElementById('start-lesson-btn')?.addEventListener('click', () => goTo('learning_home'));
  document.getElementById('signin-btn-telegram')?.addEventListener('click', () => { goTo('learning_home'); closeModal('sign_in_modal'); });
  document.getElementById('lang-en')?.addEventListener('click', () => selectLang('en', 'English', 'https://flagcdn.com/w20/us.png'));
  document.getElementById('global-continue-btn')?.addEventListener('click', handleGlobalContinue);
  document.getElementById('bottom-start-organic-btn')?.addEventListener('click', startOrganic);
  document.getElementById('sso-btn-telegram')?.addEventListener('click', () => goTo('learning_home'));
  document.getElementById('age-btn-adult')?.addEventListener('click', function() { selectAgeOption(this, 'adult'); });
  document.getElementById('hero-start-program-btn')?.addEventListener('click', startProgram);
  document.getElementById('lang-id')?.addEventListener('click', () => selectLang('id', 'Bahasa Indonesia', 'https://flagcdn.com/w20/id.png'));
  document.getElementById('save-wall-signin-btn')?.addEventListener('click', openSignInModal);
  document.getElementById('onboarding-back-btn')?.addEventListener('click', goBack);
  document.getElementById('header-signup-btn')?.addEventListener('click', startOrganic);
  document.getElementById('age-btn-adult-25')?.addEventListener('click', function() { selectAgeOption(this, 'adult_25_34', true); });
  document.getElementById('join_btn')?.addEventListener('click', submitCode);
  document.getElementById('age-btn-adult-35')?.addEventListener('click', function() { selectAgeOption(this, 'adult_35_44', true); });
  document.getElementById('signin-btn-apple')?.addEventListener('click', () => { goTo('learning_home'); closeModal('sign_in_modal'); });
  document.getElementById('hero-start-organic-btn')?.addEventListener('click', startOrganic);
  document.getElementById('age-btn-adult-45')?.addEventListener('click', function() { selectAgeOption(this, 'adult_45_54', true); });
  document.getElementById('sso-btn-google')?.addEventListener('click', () => goTo('learning_home'));
  document.getElementById('sso-btn-facebook')?.addEventListener('click', () => goTo('learning_home'));
  document.getElementById('age-btn-teen')?.addEventListener('click', function() { selectAgeOption(this, 'teen'); });
  document.getElementById('header-signin-btn')?.addEventListener('click', openSignInModal);
  document.getElementById('sso-btn-apple')?.addEventListener('click', () => goTo('learning_home'));
  document.getElementById('logo-link')?.addEventListener('click', (e) => { e.preventDefault(); goTo('landing'); });
  document.getElementById('close-signin-modal-btn')?.addEventListener('click', () => closeModal('sign_in_modal'));
  document.getElementById('signin-btn-google')?.addEventListener('click', () => { goTo('learning_home'); closeModal('sign_in_modal'); });
  document.getElementById('lang-select-selected')?.addEventListener('click', toggleSelect);
  document.getElementById('close-code-modal-btn')?.addEventListener('click', () => closeModal('code_entry_modal'));
  document.getElementById('signin-modal-signup-btn')?.addEventListener('click', () => { closeModal('sign_in_modal'); startOrganic(); });
  document.getElementById('signin-btn-facebook')?.addEventListener('click', () => { goTo('learning_home'); closeModal('sign_in_modal'); });

  const backBtn = document.getElementById('onboarding-back-btn');
  if (backBtn) {
    backBtn.addEventListener('click', goBack);
  }
  document.getElementById('name_input')?.addEventListener('input', validateName);
  document.getElementById('country_search')?.addEventListener('input', handleCountryInput);
  document.getElementById('country_search')?.addEventListener('keydown', handleCountryKeydown);

  document.getElementById('save_email_input')?.addEventListener('input', validateSaveGate);
  document.getElementById('save_password_input')?.addEventListener('input', validateSaveGate);
  document.getElementById('save_create_btn')?.addEventListener('click', () => goTo('learning_home'));

  document.getElementById('login_email_input')?.addEventListener('input', validateLoginModal);
  document.getElementById('login_password_input')?.addEventListener('input', validateLoginModal);
  document.getElementById('login_submit_btn')?.addEventListener('click', () => { goTo('learning_home'); closeModal('sign_in_modal'); });

  function validateSaveGate() {
    const email = document.getElementById('save_email_input')?.value || '';
    const pwd = document.getElementById('save_password_input')?.value || '';
    const btn = document.getElementById('save_create_btn');
    if (!btn) return;
    
    const isValidEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    const isValidPwd = pwd.length >= 6;
    
    btn.disabled = !(isValidEmail && isValidPwd);
  }

  function validateLoginModal() {
    const email = document.getElementById('login_email_input')?.value || '';
    const pwd = document.getElementById('login_password_input')?.value || '';
    const btn = document.getElementById('login_submit_btn');
    if (!btn) return;
    
    const isValidEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
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
  'name_gate': 0,
  'country_gate': 25,
  'age_gate': 50,
  'goal_intake': 75,
  'assigned_content': 75,
  'save_wall': 100,
  'learning_home': 100
};

    function updateHeaders(screenId) {
      if (screenId === 'learning_home') {
        document.body.classList.remove('is-onboarding');
        document.getElementById('global-header').style.display = 'none';
        document.getElementById('onboarding-header').style.display = 'none';
        document.getElementById('onboarding-footer').style.display = 'none';
      } else if (screenId === 'landing' || screenId === 'sign_in') {
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
                'assigned_content': 20,
                'name_gate': 40,
                'country_gate': 60,
                'age_gate': 80,
                'save_wall': 100,
                'learning_home': 100
            };
            prog = programProgressMap[screenId] || 0;
        }
        document.getElementById('progress-bar').style.width = prog + '%';
        
        const footer = document.getElementById('onboarding-footer');
        const btn = document.getElementById('global-continue-btn');
        
        if (['name_gate', 'country_gate', 'age_gate', 'goal_intake', 'assigned_content'].includes(screenId)) {
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
      if (screenId === 'learning_home') renderHomeSection();
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
      document.getElementById('code_entry_modal').classList.add('show');
    }

    function openSignInModal() {
      // Just in case they were in a card, but sign in modal floats above everything.
      document.getElementById('sign_in_modal').classList.add('show');
    }

    function closeModal(id) {
      document.getElementById(id).classList.remove('show');
    }

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

    
    function selectAgeOption(element, category, isAdultSubOption = false) {
      if (isAdultSubOption) {
        const peers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
        peers.forEach(p => p.classList.remove('selected'));
        appState.selectedAgeCategory = category;
        document.getElementById('global-continue-btn').disabled = false;
      } else {
        const peers = document.getElementById('age-primary-options').querySelectorAll('.option-card');
        peers.forEach(p => p.classList.remove('selected'));
        
        if (category === 'adult') {
          showAdultOptions();
          appState.selectedAgeCategory = null;
          document.getElementById('global-continue-btn').disabled = true;
          const subPeers = document.getElementById('age-adult-options').querySelectorAll('.option-card');
          subPeers.forEach(p => p.classList.remove('selected'));
        } else {
          hideAdultOptions();
          appState.selectedAgeCategory = category;
          document.getElementById('global-continue-btn').disabled = false;
        }
      }
      element.classList.add('selected');
    }

    function continueFromAge() {
      if (!appState.selectedAgeCategory) return;
      if (appState.entryPath === 'organic') {
        goTo('goal_intake');
      } else {
        goTo('save_wall');
        populateProfileSummary();
      }
    }

    

    function renderGoalCards() {
      const grid = document.getElementById('goal_grid');
      if (!grid) return;

      grid.innerHTML = '';
      goalOptions.forEach(goal => {
        const card = document.createElement('button');
        const isSelected = appState.selectedGoal === goal.id;
        card.type = 'button';
        card.className = `goal-card${isSelected ? ' selected' : ''}`;
        card.setAttribute('aria-pressed', isSelected.toString());
        card.innerHTML = `
          <span class="material-symbols-rounded" style="color: ${goal.color};">${goal.icon}</span>
          <span class="goal-card-title">${goal.title}</span>
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

      // Helper to highlight matching text
      const highlight = (text, q) => {
        if (!q) return text;
        const regex = new RegExp(`(${q})`, 'gi');
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
          <img class="flag-icon" src="https://flagcdn.com/w20/${country.code}.png" alt="" style="flex-shrink: 0;">
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
  
    function renderHomeSection() {
        const uName = document.getElementById('name_input').value.trim() || 'Learner';
        document.getElementById('home_greeting').innerText = `Hi, ${uName}!`;
        
        // Course mapping
        const courseMap = {
            'english': 'English for Workplace',
            'math': 'Practical Math Skills',
            'workplace': 'Workplace Communication',
            'digital_literacy': 'Digital Skills for the Modern World',
            'entrepreneurship': 'Start Your Own Business'
        };
        
        const courseTitle = courseMap[appState.selectedGoal] || 'General Skills Mastery';
        document.getElementById('home_course_title').innerText = courseTitle;
        
        // Program tasks conditional logic
        if (typeof appState.entryPath !== 'undefined' && appState.entryPath === 'program') {
            document.getElementById('home_program_tasks').style.display = 'block';
            document.getElementById('home_program_name').innerText = 'Digital Heroes';
        } else {
            document.getElementById('home_program_tasks').style.display = 'none';
        }
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
    
  
