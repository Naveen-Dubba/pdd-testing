import { useState } from 'react';
import { apiService } from '../services/api';
import { User, Mail, Calendar, AlertCircle, CheckCircle, Loader } from 'lucide-react';

export default function Profile() {
  const user = JSON.parse(localStorage.getItem('user') || '{}');
  
  const [name, setName] = useState(user.name || '');
  const [email] = useState(user.email || ''); // Email is unique and non-editable
  const [gender, setGender] = useState(user.gender || 'Male');
  const [age, setAge] = useState(user.age || '');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name) {
      setError('Name field is required.');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      await apiService.updateProfile(name, email, gender, age);
      // Update local storage
      const updatedUser = { ...user, name, gender, age: age ? parseInt(age) : null };
      localStorage.setItem('user', JSON.stringify(updatedUser));
      setSuccess('Profile updated successfully!');
      
      // Dispatch storage event to update layout sidebar
      window.dispatchEvent(new Event('storage'));
    } catch (err) {
      console.error(err);
      setError(err.message || 'Failed to update profile. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ maxWidth: '650px', margin: '0 auto' }} className="animate-slide-up">
      {/* Title */}
      <div style={{ textAlign: 'left', marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <User color="var(--primary)" />
          <span>My Profile</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)' }}>Manage your personal details and account settings.</p>
      </div>

      {success && (
        <div className="badge badge-success" style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
          padding: '0.75rem 1rem',
          borderRadius: '12px',
          marginBottom: '1.5rem',
          textAlign: 'left',
          width: '100%',
          fontSize: '0.85rem'
        }}>
          <CheckCircle size={16} style={{ flexShrink: 0 }} />
          <span>{success}</span>
        </div>
      )}

      {error && (
        <div className="badge badge-danger" style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.5rem',
          padding: '0.75rem 1rem',
          borderRadius: '12px',
          marginBottom: '1.5rem',
          textAlign: 'left',
          width: '100%',
          fontSize: '0.85rem',
          whiteSpace: 'normal'
        }}>
          <AlertCircle size={16} style={{ flexShrink: 0 }} />
          <span>{error}</span>
        </div>
      )}

      <div className="glass-card" style={{ padding: '2.5rem 2rem' }}>
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
          {/* Avatar Area */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '1.25rem', marginBottom: '1rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '1.5rem' }}>
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background: 'var(--primary-gradient)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: '700',
              fontFamily: 'var(--font-display)',
              color: '#ffffff',
              fontSize: '1.65rem',
              boxShadow: 'var(--shadow-glow)'
            }}>
              {name ? name.charAt(0).toUpperCase() : 'U'}
            </div>
            <div style={{ textAlign: 'left' }}>
              <h3 style={{ fontSize: '1.15rem', margin: 0 }}>{name || 'User Profile'}</h3>
              <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)' }}>Registered User</p>
            </div>
          </div>

          {/* Email Address - Disabled */}
          <div className="form-group">
            <label className="form-label" htmlFor="profile-email">Email Address</label>
            <div style={{ position: 'relative' }}>
              <Mail size={16} color="var(--text-muted)" style={{
                position: 'absolute',
                left: '14px',
                top: '50%',
                transform: 'translateY(-50%)'
              }} />
              <input
                type="email"
                id="profile-email"
                className="form-input"
                value={email}
                disabled
                style={{ paddingLeft: '2.5rem', opacity: 0.5, cursor: 'not-allowed' }}
              />
            </div>
            <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', display: 'block', marginTop: '0.25rem', paddingLeft: '0.25rem' }}>
              Email address cannot be changed.
            </span>
          </div>

          {/* Full Name */}
          <div className="form-group">
            <label className="form-label" htmlFor="profile-name">Full Name</label>
            <div style={{ position: 'relative' }}>
              <User size={16} color="var(--text-muted)" style={{
                position: 'absolute',
                left: '14px',
                top: '50%',
                transform: 'translateY(-50%)'
              }} />
              <input
                type="text"
                id="profile-name"
                className="form-input"
                value={name}
                onChange={(e) => setName(e.target.value)}
                style={{ paddingLeft: '2.5rem' }}
                disabled={loading}
                required
              />
            </div>
          </div>

          {/* Gender and Age Grid */}
          <div className="grid-2">
            <div className="form-group">
              <label className="form-label" htmlFor="profile-gender">Gender</label>
              <select
                id="profile-gender"
                className="form-select"
                value={gender}
                onChange={(e) => setGender(e.target.value)}
                disabled={loading}
              >
                <option value="Male">Male</option>
                <option value="Female">Female</option>
                <option value="Other">Other</option>
              </select>
            </div>

            <div className="form-group">
              <label className="form-label" htmlFor="profile-age">Age</label>
              <div style={{ position: 'relative' }}>
                <Calendar size={16} color="var(--text-muted)" style={{
                  position: 'absolute',
                  left: '14px',
                  top: '50%',
                  transform: 'translateY(-50%)'
                }} />
                <input
                  type="number"
                  id="profile-age"
                  className="form-input"
                  placeholder="25"
                  value={age}
                  onChange={(e) => setAge(e.target.value)}
                  style={{ paddingLeft: '2.5rem' }}
                  disabled={loading}
                  min="1"
                  max="120"
                />
              </div>
            </div>
          </div>

          <button
            type="submit"
            className="btn btn-primary"
            style={{
              padding: '0.8rem 2rem',
              alignSelf: 'flex-start',
              marginTop: '1rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem'
            }}
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader size={16} className="spinner" style={{ animationDuration: '0.8s' }} />
                <span>Saving...</span>
              </>
            ) : (
              <span>Save Changes</span>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
