/* ====================================================================
   MIT Socials - Student Profile JavaScript
   ==================================================================== */

document.addEventListener('DOMContentLoaded', async () => {
    const session = await checkAuthSession(true);
    if (!session || !session.loggedIn) return;

    loadProfileData();
    setupEditProfileModal();
});

async function loadProfileData() {
    try {
        const response = await fetch('api/profile', {
            method: 'GET',
            headers: { 'Accept': 'application/json' }
        });
        const data = await response.json();

        if (data.success) {
            renderProfile(data.user, data.profile);
        } else {
            console.error('Failed to load profile data:', data.message);
        }
    } catch (err) {
        console.error('Profile fetch error:', err);
    }
}

function renderProfile(user, profile) {
    // Basic Details
    document.getElementById('profile-full-name').textContent = user.fullName;
    document.getElementById('profile-student-id').textContent = `PRN: ${user.studentId}`;
    document.getElementById('profile-email').textContent = user.collegeEmail;
    document.getElementById('profile-academic').textContent = `${user.branch} • ${user.year} • Division ${user.division}`;
    document.getElementById('profile-role-badge').textContent = user.role;
    document.getElementById('profile-role-badge').className = `badge badge-${user.role.toLowerCase().replace('_', '-')}`;

    // Profile Bio
    const bioText = document.getElementById('profile-bio');
    if (bioText) {
        bioText.textContent = (profile && profile.bio) ? profile.bio : 'No bio added yet. Click "Edit Profile" to share something about yourself!';
    }

    // Profile Photo & Cover Photo
    const avatarImg = document.getElementById('profile-avatar-img');
    if (avatarImg && profile && profile.profilePhoto) {
        avatarImg.src = profile.profilePhoto;
    }

    const coverBg = document.getElementById('profile-cover-bg');
    if (coverBg && profile && profile.coverPhoto) {
        coverBg.style.backgroundImage = `url('${profile.coverPhoto}')`;
    }

    // Populate modal form defaults
    if (profile) {
        document.getElementById('edit-bio').value = profile.bio || '';
        document.getElementById('edit-profile-photo').value = profile.profilePhoto || '';
        document.getElementById('edit-cover-photo').value = profile.coverPhoto || '';
    }
}

function setupEditProfileModal() {
    const editBtn = document.getElementById('open-edit-modal');
    const modal = document.getElementById('edit-profile-modal');
    const closeBtn = document.getElementById('close-modal');
    const editForm = document.getElementById('edit-profile-form');

    if (!editBtn || !modal) return;

    editBtn.addEventListener('click', () => {
        modal.style.display = 'flex';
    });

    if (closeBtn) {
        closeBtn.addEventListener('click', () => {
            modal.style.display = 'none';
        });
    }

    // Close when clicking outside modal box
    window.addEventListener('click', (e) => {
        if (e.target === modal) {
            modal.style.display = 'none';
        }
    });

    // Form submit handler
    if (editForm) {
        editForm.addEventListener('submit', async (e) => {
            e.preventDefault();

            const bio = document.getElementById('edit-bio').value.trim();
            const profilePhoto = document.getElementById('edit-profile-photo').value.trim();
            const coverPhoto = document.getElementById('edit-cover-photo').value.trim();

            const submitBtn = editForm.querySelector('button[type="submit"]');
            submitBtn.disabled = true;
            submitBtn.textContent = 'Saving...';

            try {
                const response = await fetch('api/profile', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: new URLSearchParams({
                        bio: bio,
                        profile_photo: profilePhoto,
                        cover_photo: coverPhoto
                    })
                });

                const data = await response.json();

                if (data.success) {
                    renderProfile(data.user, data.profile);
                    modal.style.display = 'none';
                    showAlert('profile-alert-box', 'Profile updated successfully!', 'success');
                } else {
                    alert(data.message || 'Failed to update profile.');
                }
            } catch (err) {
                console.error('Update profile error:', err);
                alert('Connection error. Could not save profile updates.');
            } finally {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Save Changes';
            }
        });
    }
}
