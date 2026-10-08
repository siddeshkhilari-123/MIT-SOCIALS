/* ====================================================================
   MIT Socials - Dashboard JavaScript
   ==================================================================== */

document.addEventListener('DOMContentLoaded', async () => {
    const session = await checkAuthSession(true);
    if (!session || !session.loggedIn) return;

    renderDashboard(session);
    setupLogoutHandler();
});

function renderDashboard(session) {
    const user = session.user;
    const profile = session.profile;

    // Set Welcome Header
    const welcomeName = document.getElementById('user-welcome-name');
    if (welcomeName) {
        welcomeName.textContent = user.fullName || 'Student';
    }

    // Set Profile Summary Elements
    const studentName = document.getElementById('student-name');
    if (studentName) studentName.textContent = user.fullName;

    const studentBranchYear = document.getElementById('student-branch-year');
    if (studentBranchYear) {
        studentBranchYear.textContent = `${user.branch} • ${user.year} (Div ${user.division})`;
    }

    const studentIdBadge = document.getElementById('student-id');
    if (studentIdBadge) {
        studentIdBadge.textContent = `PRN: ${user.studentId}`;
    }

    const roleBadge = document.getElementById('user-role-badge');
    if (roleBadge) {
        roleBadge.textContent = user.role;
        roleBadge.className = `badge badge-${user.role.toLowerCase().replace('_', '-')}`;
    }

    // Set Avatar Image if present
    const avatarImg = document.getElementById('user-avatar');
    if (avatarImg && profile && profile.profilePhoto) {
        avatarImg.src = profile.profilePhoto;
    }
}

function setupLogoutHandler() {
    const logoutBtns = document.querySelectorAll('.logout-btn');
    logoutBtns.forEach(btn => {
        btn.addEventListener('click', async (e) => {
            e.preventDefault();
            try {
                const response = await fetch('api/logout', {
                    method: 'POST',
                    headers: { 'Accept': 'application/json' }
                });
                const data = await response.json();
                if (data.success) {
                    window.location.href = 'login.html';
                }
            } catch (err) {
                window.location.href = 'login.html';
            }
        });
    });
}
