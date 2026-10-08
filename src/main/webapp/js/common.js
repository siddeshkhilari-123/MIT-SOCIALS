/* ====================================================================
   MIT Socials - Common Utilities (Vanilla JS)
   ==================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    initTheme();
    setupThemeToggle();
});

/**
 * Initializes light/dark theme preference from localStorage or system theme.
 */
function initTheme() {
    const savedTheme = localStorage.getItem('mit_socials_theme');
    if (savedTheme) {
        document.documentElement.setAttribute('data-theme', savedTheme);
        updateThemeToggleButton(savedTheme);
    } else {
        const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        const theme = prefersDark ? 'dark' : 'light';
        document.documentElement.setAttribute('data-theme', theme);
        updateThemeToggleButton(theme);
    }
}

/**
 * Sets up theme toggle button listener.
 */
function setupThemeToggle() {
    const toggleBtn = document.getElementById('theme-toggle');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', () => {
            const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('mit_socials_theme', newTheme);
            updateThemeToggleButton(newTheme);
        });
    }
}

function updateThemeToggleButton(theme) {
    const toggleBtn = document.getElementById('theme-toggle');
    if (toggleBtn) {
        toggleBtn.innerHTML = theme === 'dark' ? '☀️ Light' : '🌙 Dark';
    }
}

/**
 * Displays an alert message in a container.
 */
function showAlert(containerId, message, type = 'error') {
    const container = document.getElementById(containerId);
    if (!container) return;

    container.className = `alert alert-${type}`;
    container.textContent = message;
    container.style.display = 'block';
}

/**
 * Hides an alert box.
 */
function hideAlert(containerId) {
    const container = document.getElementById(containerId);
    if (container) {
        container.style.display = 'none';
    }
}

/**
 * Checks session and redirects to login if unauthenticated for protected pages.
 */
async function checkAuthSession(redirectIfUnauth = true) {
    try {
        const response = await fetch('api/session', {
            method: 'GET',
            headers: { 'Accept': 'application/json' }
        });
        const data = await response.json();
        
        if (!data.loggedIn && redirectIfUnauth) {
            window.location.href = 'login.html';
            return null;
        }
        return data;
    } catch (err) {
        console.error('Session check failed:', err);
        if (redirectIfUnauth) {
            window.location.href = 'login.html';
        }
        return null;
    }
}
