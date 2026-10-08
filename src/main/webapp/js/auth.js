/* ====================================================================
   MIT Socials - Authentication JavaScript (Login & Register)
   ==================================================================== */

document.addEventListener('DOMContentLoaded', () => {
    setupPasswordToggle();
    setupLoginForm();
    setupRegisterForm();
    checkExistingSessionOnAuthPages();
});

/**
 * If user is already logged in, redirect them from login/register to dashboard.
 */
async function checkExistingSessionOnAuthPages() {
    const loginForm = document.getElementById('login-form');
    const registerForm = document.getElementById('register-form');
    if (loginForm || registerForm) {
        try {
            const res = await fetch('api/session');
            const data = await res.json();
            if (data.loggedIn) {
                window.location.href = 'dashboard.html';
            }
        } catch (e) {
            // Ignore session check errors on auth pages
        }
    }
}

/**
 * Setup show/hide password buttons.
 */
function setupPasswordToggle() {
    const toggleBtns = document.querySelectorAll('.password-toggle-btn');
    toggleBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            e.preventDefault();
            const input = btn.previousElementSibling || btn.parentElement.querySelector('input');
            if (input) {
                const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
                input.setAttribute('type', type);
                btn.textContent = type === 'password' ? 'Show' : 'Hide';
            }
        });
    });
}

/**
 * Handles Login submission.
 */
function setupLoginForm() {
    const loginForm = document.getElementById('login-form');
    if (!loginForm) return;

    loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideAlert('alert-box');

        const collegeEmail = document.getElementById('college_email').value.trim();
        const password = document.getElementById('password').value;

        if (!collegeEmail || !password) {
            showAlert('alert-box', 'Please fill in all fields.');
            return;
        }

        const submitBtn = loginForm.querySelector('button[type="submit"]');
        const originalBtnText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = 'Logging in...';

        try {
            const response = await fetch('api/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                },
                body: new URLSearchParams({
                    college_email: collegeEmail,
                    password: password
                })
            });

            const data = await response.json();

            if (data.success) {
                showAlert('alert-box', data.message || 'Login successful!', 'success');
                setTimeout(() => {
                    window.location.href = data.redirect || 'dashboard.html';
                }, 800);
            } else {
                showAlert('alert-box', data.message || 'Invalid credentials.');
                submitBtn.disabled = false;
                submitBtn.textContent = originalBtnText;
            }
        } catch (err) {
            console.error('Login error:', err);
            showAlert('alert-box', 'Server connection error. Please try again later.');
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
        }
    });
}

/**
 * Handles Register submission.
 */
function setupRegisterForm() {
    const registerForm = document.getElementById('register-form');
    if (!registerForm) return;

    registerForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        hideAlert('alert-box');

        const fullName = document.getElementById('full_name').value.trim();
        const collegeEmail = document.getElementById('college_email').value.trim();
        const studentId = document.getElementById('student_id').value.trim();
        const branch = document.getElementById('branch').value;
        const year = document.getElementById('year').value;
        const division = document.getElementById('division').value;
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirm_password').value;

        // Validation
        if (!fullName || !collegeEmail || !studentId || !branch || !year || !division || !password || !confirmPassword) {
            showAlert('alert-box', 'Please fill in all fields.');
            return;
        }

        if (password !== confirmPassword) {
            showAlert('alert-box', 'Passwords do not match.');
            return;
        }

        if (password.length < 6) {
            showAlert('alert-box', 'Password must be at least 6 characters long.');
            return;
        }

        const submitBtn = registerForm.querySelector('button[type="submit"]');
        const originalBtnText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = 'Creating account...';

        try {
            const response = await fetch('api/register', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                },
                body: new URLSearchParams({
                    full_name: fullName,
                    college_email: collegeEmail,
                    student_id: studentId,
                    branch: branch,
                    year: year,
                    division: division,
                    password: password,
                    confirm_password: confirmPassword
                })
            });

            const data = await response.json();

            if (data.success) {
                showAlert('alert-box', data.message || 'Registration successful! Redirecting to login...', 'success');
                setTimeout(() => {
                    window.location.href = 'login.html';
                }, 1500);
            } else {
                showAlert('alert-box', data.message || 'Registration failed.');
                submitBtn.disabled = false;
                submitBtn.textContent = originalBtnText;
            }
        } catch (err) {
            console.error('Registration error:', err);
            showAlert('alert-box', 'Server connection error. Please try again later.');
            submitBtn.disabled = false;
            submitBtn.textContent = originalBtnText;
        }
    });
}
