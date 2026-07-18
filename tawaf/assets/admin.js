(() => {
  const menuButton = document.querySelector('[data-menu-button]');
  const sidebar = document.querySelector('#sidebar');
  if (menuButton && sidebar) {
    menuButton.addEventListener('click', () => {
      const open = sidebar.classList.toggle('open');
      menuButton.setAttribute('aria-expanded', String(open));
    });
    document.addEventListener('click', (event) => {
      if (window.innerWidth <= 900 && sidebar.classList.contains('open') &&
          !sidebar.contains(event.target) && !menuButton.contains(event.target)) {
        sidebar.classList.remove('open');
        menuButton.setAttribute('aria-expanded', 'false');
      }
    });
  }

  document.querySelectorAll('[data-password-toggle]').forEach((button) => {
    button.addEventListener('click', () => {
      const input = button.closest('.password-field')?.querySelector('[data-password-input]');
      if (!input) return;
      const showing = input.type === 'text';
      input.type = showing ? 'password' : 'text';
      button.textContent = showing ? 'Show' : 'Hide';
      button.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
    });
  });

  document.querySelectorAll('[data-confirm]').forEach((control) => {
    control.addEventListener('click', (event) => {
      if (!window.confirm(control.dataset.confirm || 'Are you sure?')) {
        event.preventDefault();
      }
    });
  });

  const alert = document.querySelector('.page-content > .alert.success');
  if (alert) {
    window.setTimeout(() => {
      alert.style.opacity = '0';
      alert.style.transition = 'opacity .25s ease';
      window.setTimeout(() => alert.remove(), 300);
    }, 4500);
  }
})();
