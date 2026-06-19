import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { apiService } from '../services/api';
import { Lock, Mail, Shirt, AlertCircle, Loader } from 'lucide-react';

export default function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  // If already logged in, redirect to home
  useEffect(() => {
    if (localStorage.getItem('user')) {
      navigate('/', { replace: true });
    }
  }, [navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please fill in all fields.');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await apiService.login(email, password);
      // Store user info in localStorage
      localStorage.setItem('user', JSON.stringify(response.user));
      navigate('/');
    } catch (err) {
      console.error(err);
      setError(err.message || 'Invalid email or password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'radial-gradient(circle at top right, #1a153b 0%, var(--bg-primary) 60%)',
      padding: '1.5rem'
    }} className="animate-fade-in">
      <div className="glass-card animate-scale-in" style={{
        maxWidth: '420px',
        width: '100%',
        padding: '2.5rem 2rem',
        borderRadius: '24px',
        textAlign: 'center',
        boxShadow: '0 20px 50px rgba(0,0,0,0.4)',
        border: '1px solid rgba(255, 255, 255, 0.08)'
      }}>
        {/* Logo */}
        <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: '0.75rem', marginBottom: '1.5rem' }}>
          <div style={{
            background: 'var(--primary-gradient)',
            padding: '0.85rem',
            borderRadius: '16px',
            boxShadow: 'var(--shadow-glow)'
          }}>
            <Shirt size={28} color="#ffffff" />
          </div>
        </div>

        <h1 style={{
          fontSize: '1.85rem',
          fontWeight: 800,
          marginBottom: '0.5rem',
          fontFamily: 'var(--font-display)',
          color: '#ffffff'
        }}>
          Welcome Back
        </h1>
        <p style={{
          fontSize: '0.9rem',
          color: 'var(--text-secondary)',
          marginBottom: '2rem'
        }}>
          Sign in to access your personalized AI wardrobe stylist
        </p>

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

        <form onSubmit={handleSubmit}>
          {/* Email input */}
          <div className="form-group" style={{ position: 'relative' }}>
            <label className="form-label" htmlFor="email">Email Address</label>
            <div style={{ position: 'relative' }}>
              <Mail size={16} color="var(--text-muted)" style={{
                position: 'absolute',
                left: '14px',
                top: '50%',
                transform: 'translateY(-50%)'
              }} />
              <input
                type="email"
                id="email"
                className="form-input"
                placeholder="you@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                style={{ paddingLeft: '2.5rem' }}
                disabled={loading}
                required
              />
            </div>
          </div>

          {/* Password input */}
          <div className="form-group" style={{ position: 'relative' }}>
            <label className="form-label" htmlFor="password">Password</label>
            <div style={{ position: 'relative' }}>
              <Lock size={16} color="var(--text-muted)" style={{
                position: 'absolute',
                left: '14px',
                top: '50%',
                transform: 'translateY(-50%)'
              }} />
              <input
                type="password"
                id="password"
                className="form-input"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                style={{ paddingLeft: '2.5rem' }}
                disabled={loading}
                required
              />
            </div>
          </div>

          <button
            type="submit"
            id="login-button"
            className="btn btn-primary btn-full"
            style={{
              padding: '0.9rem',
              marginTop: '1rem',
              fontSize: '1rem',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem'
            }}
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader size={18} className="spinner" style={{ width: '18px', height: '18px', animationDuration: '0.8s' }} />
                <span>Signing In...</span>
              </>
            ) : (
              <span>Sign In</span>
            )}
          </button>
        </form>

        <div style={{ marginTop: '1.75rem', fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
          Don't have an account?{' '}
          <Link to="/register" style={{ fontWeight: '600', color: 'var(--primary)' }}>
            Sign Up
          </Link>
        </div>
      </div>
    </div>
  );
}
