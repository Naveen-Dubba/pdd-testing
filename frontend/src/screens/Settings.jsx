import React, { useState } from 'react';
import { Settings as SettingsIcon, Key, Info, HelpCircle, Save, CheckCircle } from 'lucide-react';

export default function Settings() {
  const [apiKey, setApiKey] = useState(localStorage.getItem('groq_api_key') || '');
  const [success, setSuccess] = useState('');
  
  const handleSaveKeys = (e) => {
    e.preventDefault();
    setSuccess('');
    
    if (apiKey.trim()) {
      localStorage.setItem('groq_api_key', apiKey.trim());
    } else {
      localStorage.removeItem('groq_api_key');
    }
    
    setSuccess('API keys updated successfully!');
    setTimeout(() => setSuccess(''), 3000);
  };

  return (
    <div style={{ maxWidth: '650px', margin: '0 auto' }} className="animate-slide-up">
      {/* Title */}
      <div style={{ textAlign: 'left', marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <SettingsIcon color="var(--primary)" />
          <span>Settings</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)' }}>Configure API keys, theme modes, and view application information.</p>
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
          <CheckCircle size={16} />
          <span>{success}</span>
        </div>
      )}

      <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
        {/* API Key Panel */}
        <div className="glass-card" style={{ padding: '2rem', textAlign: 'left' }}>
          <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '1.25rem', marginBottom: '1rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.5rem' }}>
            <Key size={18} color="var(--primary)" />
            <span>Developer Credentials</span>
          </h2>
          
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '1.25rem' }}>
            By default, AI Vastra uses a shared developer Groq API key for vision analysis and style chat. You can specify your own private key below to prevent rate limits.
          </p>

          <form onSubmit={handleSaveKeys} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <div className="form-group" style={{ marginBottom: 0 }}>
              <label className="form-label" htmlFor="settings-groq-key">Custom Groq API Key</label>
              <input
                type="password"
                id="settings-groq-key"
                className="form-input"
                placeholder="gsk_..."
                value={apiKey}
                onChange={(e) => setApiKey(e.target.value)}
              />
            </div>
            
            <button type="submit" className="btn btn-primary" style={{ alignSelf: 'flex-start', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <Save size={16} />
              <span>Save Credentials</span>
            </button>
          </form>
        </div>

        {/* System Info Panel */}
        <div className="glass-card" style={{ padding: '2rem', textAlign: 'left' }}>
          <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '1.25rem', marginBottom: '1rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.5rem' }}>
            <Info size={18} color="var(--accent)" />
            <span>System Information</span>
          </h2>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', fontSize: '0.9rem' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.02)', paddingBottom: '0.5rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Flask API Base URL</span>
              <code style={{ fontSize: '0.8rem' }}>{import.meta.env.VITE_API_URL || 'http://localhost:5000'}</code>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.02)', paddingBottom: '0.5rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Vision Model</span>
              <code style={{ fontSize: '0.8rem' }}>llama-4-scout-17b</code>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,0.02)', paddingBottom: '0.5rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Chat Stylist Model</span>
              <code style={{ fontSize: '0.8rem' }}>llama-3.1-8b-instant</code>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', paddingBottom: '0.5rem' }}>
              <span style={{ color: 'var(--text-secondary)' }}>App Build Version</span>
              <code style={{ fontSize: '0.8rem' }}>v1.0.0-react</code>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
