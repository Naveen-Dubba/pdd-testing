import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { apiService } from '../services/api';
import { Sparkles, MessageSquare, History, Activity, Calendar, Shirt, ChevronRight, RefreshCw, AlertCircle } from 'lucide-react';

export default function Dashboard() {
  const [stats, setStats] = useState({ total_analyses: 0, latest: null });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const user = JSON.parse(localStorage.getItem('user') || '{}');

  const fetchDashboardData = async () => {
    if (!user.id) return;
    setLoading(true);
    setError('');
    try {
      const data = await apiService.getDashboard(user.id);
      setStats(data);
    } catch (err) {
      console.error('Failed to load dashboard:', err);
      setError('Could not connect to Flask server. Please make sure the backend API is running.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  return (
    <div className="animate-slide-up" style={{ display: 'flex', flexDirection: 'column', gap: '2rem' }}>
      {/* Welcome Banner */}
      <div className="glass" style={{
        padding: '2.5rem 2rem',
        borderRadius: '24px',
        background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.1) 0%, rgba(217, 70, 239, 0.05) 100%)',
        border: '1px solid rgba(99, 102, 241, 0.15)',
        textAlign: 'left',
        position: 'relative',
        overflow: 'hidden'
      }}>
        {/* Glow decoration */}
        <div style={{
          position: 'absolute',
          top: '-50%',
          right: '-10%',
          width: '300px',
          height: '300px',
          background: 'radial-gradient(circle, rgba(139,92,246,0.3) 0%, transparent 70%)',
          filter: 'blur(30px)',
          zIndex: 0
        }} />

        <div style={{ position: 'relative', zIndex: 1 }}>
          <h1 style={{ fontSize: '2.25rem', marginBottom: '0.5rem', fontWeight: '800' }}>
            Hello, <span className="gradient-text-accent" style={{ fontWeight: '800' }}>{user.name}</span>
          </h1>
          <p style={{ fontSize: '1.05rem', color: 'var(--text-secondary)', maxWidth: '600px', marginBottom: '1.5rem' }}>
            Ready to find your perfect style today? Upload a face photo for automated color and shape analysis, or chat directly with our AI fashion stylist.
          </p>
          <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap' }}>
            <Link to="/analyze" className="btn btn-primary">
              <Sparkles size={16} />
              Start New Analysis
            </Link>
            <Link to="/chatbot" className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
              <MessageSquare size={16} />
              Style Chat
            </Link>
          </div>
        </div>
      </div>

      {error && (
        <div className="badge badge-warning" style={{
          display: 'flex',
          alignItems: 'center',
          gap: '0.75rem',
          padding: '1rem',
          borderRadius: '14px',
          fontSize: '0.9rem',
          textAlign: 'left',
          width: '100%',
          whiteSpace: 'normal',
          justifyContent: 'space-between'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <AlertCircle size={18} style={{ flexShrink: 0 }} />
            <span>{error}</span>
          </div>
          <button 
            onClick={fetchDashboardData} 
            className="btn btn-outline btn-sm"
            style={{ padding: '0.25rem 0.5rem', display: 'flex', alignItems: 'center', gap: '0.25rem', borderRadius: '8px' }}
          >
            <RefreshCw size={12} />
            <span>Retry</span>
          </button>
        </div>
      )}

      {/* Main Grid: Info Cards */}
      <div className="grid-2">
        {/* Quick Stats Card */}
        <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', textAlign: 'left' }}>
          <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '1.35rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.75rem' }}>
            <Activity size={20} color="var(--primary)" />
            <span>Quick Actions</span>
          </h2>

          <div style={{ display: 'flex', gap: '1.5rem', flexWrap: 'wrap' }}>
            {/* Metric Item 1 */}
            <div style={{
              flex: '1 1 150px',
              background: 'var(--bg-tertiary)',
              padding: '1.25rem',
              borderRadius: '16px',
              border: '1px solid var(--border-color)',
              textAlign: 'center'
            }}>
              <div style={{ fontSize: '0.8rem', textTransform: 'uppercase', color: 'var(--text-secondary)', letterSpacing: '0.05em', marginBottom: '0.25rem' }}>
                Total Analyses
              </div>
              <div style={{ fontSize: '2.5rem', fontWeight: '800', fontFamily: 'var(--font-display)', color: '#ffffff' }}>
                {loading ? '...' : stats.total_analyses}
              </div>
            </div>

            {/* Metric Item 2 */}
            <div style={{
              flex: '1 1 150px',
              background: 'var(--bg-tertiary)',
              padding: '1.25rem',
              borderRadius: '16px',
              border: '1px solid var(--border-color)',
              textAlign: 'center'
            }}>
              <div style={{ fontSize: '0.8rem', textTransform: 'uppercase', color: 'var(--text-secondary)', letterSpacing: '0.05em', marginBottom: '0.25rem' }}>
                Member Since
              </div>
              <div style={{ fontSize: '1.5rem', fontWeight: '700', fontFamily: 'var(--font-display)', color: '#ffffff', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', minHeight: '3.75rem' }}>
                June 2026
              </div>
            </div>
          </div>

          <div style={{ marginTop: 'auto' }}>
            <Link to="/history" style={{ display: 'inline-flex', alignItems: 'center', gap: '0.25rem', fontSize: '0.9rem', fontWeight: '600' }}>
              <span>View full analysis history</span>
              <ChevronRight size={14} />
            </Link>
          </div>
        </div>

        {/* Latest Recommendation Card */}
        <div className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem', textAlign: 'left' }}>
          <h2 style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', fontSize: '1.35rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.75rem' }}>
            <Sparkles size={20} color="var(--accent)" />
            <span>Style Recommendation</span>
          </h2>

          {loading ? (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', flexGrow: 1, minHeight: '120px' }}>
              <Loader className="spinner" style={{ animationDuration: '0.8s' }} />
            </div>
          ) : stats.latest ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', flexGrow: 1 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <span className="badge badge-purple" style={{ fontSize: '0.85rem' }}>
                  {stats.latest.style_personality}
                </span>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                  <Calendar size={12} />
                  {stats.latest.created_at}
                </span>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginTop: '0.5rem' }}>
                <div style={{ background: 'rgba(255,255,255,0.02)', padding: '0.75rem', borderRadius: '12px', border: '1px solid var(--border-color)' }}>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Skin Tone</div>
                  <div style={{ fontSize: '0.95rem', fontWeight: '600', color: '#ffffff' }}>{stats.latest.skin_tone}</div>
                </div>

                <div style={{ background: 'rgba(255,255,255,0.02)', padding: '0.75rem', borderRadius: '12px', border: '1px solid var(--border-color)' }}>
                  <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Best Color</div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginTop: '0.15rem' }}>
                    <div style={{
                      width: '12px',
                      height: '12px',
                      borderRadius: '50%',
                      backgroundColor: stats.latest.best_color.toLowerCase(),
                      border: '1px solid #ffffff'
                    }} />
                    <span style={{ fontSize: '0.95rem', fontWeight: '600', color: '#ffffff' }}>{stats.latest.best_color}</span>
                  </div>
                </div>
              </div>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', flexGrow: 1, minHeight: '120px', color: 'var(--text-secondary)' }}>
              <Shirt size={32} color="var(--text-muted)" style={{ marginBottom: '0.75rem', opacity: 0.5 }} />
              <p style={{ fontSize: '0.9rem' }}>No style profiles generated yet.</p>
              <Link to="/analyze" style={{ fontSize: '0.85rem', fontWeight: '600', marginTop: '0.5rem' }}>
                Analyze your face now
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
