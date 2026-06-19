import React, { useState, useEffect } from 'react';
import { apiService } from '../services/api';
import { History as HistoryIcon, Trash2, Calendar, Sparkles, Loader, AlertCircle, RefreshCw, Eye } from 'lucide-react';

export default function History() {
  const [analyses, setAnalyses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [selectedAnalysis, setSelectedAnalysis] = useState(null); // Detail modal state

  const user = JSON.parse(localStorage.getItem('user') || '{}');

  const fetchHistory = async () => {
    if (!user.id) return;
    setLoading(true);
    setError('');
    try {
      const data = await apiService.getAnalyses(user.id);
      setAnalyses(data);
    } catch (err) {
      console.error('Failed to load history:', err);
      setError('Could not connect to Flask server. Please make sure the backend is running.');
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this styling record?')) return;
    
    try {
      await apiService.deleteAnalysis(id);
      setAnalyses(prev => prev.filter(item => item.id !== id));
      if (selectedAnalysis?.id === id) setSelectedAnalysis(null);
    } catch (err) {
      console.error('Failed to delete analysis:', err);
      alert('Failed to delete the record. Please try again.');
    }
  };

  const handleClearAll = async () => {
    if (!window.confirm('Are you sure you want to permanently clear your entire styling history? This cannot be undone.')) return;
    
    try {
      await apiService.clearAnalyses(user.id);
      setAnalyses([]);
      setSelectedAnalysis(null);
    } catch (err) {
      console.error('Failed to clear history:', err);
      alert('Failed to clear history. Please try again.');
    }
  };

  useEffect(() => {
    fetchHistory();
  }, []);

  return (
    <div className="animate-slide-up" style={{ display: 'flex', flexDirection: 'column', gap: '2rem', minHeight: '100%' }}>
      {/* Top Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '1rem' }}>
        <div style={{ textAlign: 'left' }}>
          <h1 style={{ fontSize: '2rem', marginBottom: '0.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <HistoryIcon color="var(--primary)" />
            <span>Styling History</span>
          </h1>
          <p style={{ color: 'var(--text-secondary)' }}>View and manage your saved fashion profiles, recommendations, and parameters.</p>
        </div>

        {analyses.length > 0 && (
          <button onClick={handleClearAll} className="btn btn-danger" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
            <Trash2 size={16} />
            <span>Clear All History</span>
          </button>
        )}
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
            onClick={fetchHistory} 
            className="btn btn-outline btn-sm"
            style={{ padding: '0.25rem 0.5rem', display: 'flex', alignItems: 'center', gap: '0.25rem', borderRadius: '8px' }}
          >
            <RefreshCw size={12} />
            <span>Retry</span>
          </button>
        </div>
      )}

      {/* Main Content Pane */}
      {loading ? (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '200px', flexGrow: 1 }}>
          <Loader className="spinner" style={{ animationDuration: '0.8s' }} />
        </div>
      ) : analyses.length === 0 ? (
        <div className="glass-card" style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '4rem 2rem',
          color: 'var(--text-secondary)',
          textAlign: 'center'
        }}>
          <HistoryIcon size={48} color="var(--text-muted)" style={{ marginBottom: '1.25rem', opacity: 0.5 }} />
          <h3 style={{ fontSize: '1.25rem', marginBottom: '0.5rem' }}>No Styling Records Found</h3>
          <p style={{ fontSize: '0.9rem', maxWidth: '400px', marginBottom: '1.5rem' }}>
            You haven't run any styling analyses yet. Create your first profile to begin compiling history.
          </p>
          <a href="#/analyze" className="btn btn-primary">
            <Sparkles size={16} />
            <span>Perform Styling Analysis</span>
          </a>
        </div>
      ) : (
        <div className="grid-2">
          {/* Timeline Cards List */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
            {analyses.map((item) => (
              <div 
                key={item.id} 
                className="glass-card" 
                onClick={() => setSelectedAnalysis(item)}
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  padding: '1.25rem 1.5rem',
                  cursor: 'pointer',
                  textAlign: 'left',
                  borderLeft: selectedAnalysis?.id === item.id ? '4px solid var(--primary)' : '1px solid var(--border-color)',
                  backgroundColor: selectedAnalysis?.id === item.id ? 'var(--bg-tertiary)' : 'var(--card-bg)'
                }}
              >
                <div style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', overflow: 'hidden' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', flexWrap: 'wrap' }}>
                    <span className="badge badge-purple" style={{ fontSize: '0.75rem' }}>{item.style_personality}</span>
                    <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                      <Calendar size={12} />
                      {item.created_at}
                    </span>
                  </div>
                  <div style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
                    Gender: {item.gender} • Skin Tone: {item.skin_tone} • Face: {item.face_shape}
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '0.5rem', flexShrink: 0 }} onClick={(e) => e.stopPropagation()}>
                  <button 
                    onClick={() => setSelectedAnalysis(item)}
                    className="btn btn-outline btn-sm"
                    style={{ padding: '0.4rem', borderRadius: '10px' }}
                    title="View details"
                  >
                    <Eye size={14} />
                  </button>
                  <button 
                    onClick={() => handleDelete(item.id)}
                    className="btn btn-danger btn-sm"
                    style={{ padding: '0.4rem', borderRadius: '10px' }}
                    title="Delete record"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              </div>
            ))}
          </div>

          {/* Details Panel View */}
          <div className="glass-card" style={{
            position: 'sticky',
            top: '90px',
            height: 'fit-content',
            textAlign: 'left',
            display: 'flex',
            flexDirection: 'column',
            gap: '1.5rem',
            padding: '2rem'
          }}>
            {selectedAnalysis ? (
              <div className="animate-fade-in" style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                <div style={{ borderBottom: '1px solid var(--border-color)', paddingBottom: '0.75rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <h3 style={{ fontSize: '1.35rem', margin: 0 }}>Styling Parameters</h3>
                  <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <Calendar size={12} />
                    {selectedAnalysis.created_at}
                  </span>
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Gender</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.gender}</div>
                    </div>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Face Shape</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.face_shape}</div>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Skin Tone</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.skin_tone}</div>
                    </div>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Body Type</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.body_type || 'N/A'}</div>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Suggested Size</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.size_suggestion || 'N/A'}</div>
                    </div>
                    <div>
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)', textTransform: 'uppercase' }}>Style Personality</span>
                      <div style={{ fontSize: '1.05rem', fontWeight: '600', color: 'var(--primary)' }}>{selectedAnalysis.style_personality}</div>
                    </div>
                  </div>
                </div>

                <div style={{
                  borderTop: '1px solid var(--border-color)',
                  paddingTop: '1.25rem',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between'
                }}>
                  <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', fontWeight: '500' }}>Matching Color Palette</span>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                    <div style={{
                      width: '16px',
                      height: '16px',
                      borderRadius: '50%',
                      backgroundColor: (selectedAnalysis.best_color || 'blue').toLowerCase(),
                      border: '1px solid #ffffff',
                      boxShadow: 'var(--shadow-sm)'
                    }} />
                    <span style={{ fontWeight: '600', color: '#ffffff' }}>{selectedAnalysis.best_color || 'Blue'}</span>
                  </div>
                </div>
              </div>
            ) : (
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                minHeight: '220px',
                color: 'var(--text-muted)',
                textAlign: 'center'
              }}>
                <Eye size={32} style={{ marginBottom: '0.5rem', opacity: 0.4 }} />
                <p style={{ fontSize: '0.9rem', maxWidth: '250px' }}>Select any record on the left to view detailed styling analysis parameters.</p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
