import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { apiService } from '../services/api';
import { groqService } from '../services/groq';
import { Sparkles, Upload, Loader, Image, RefreshCw, AlertCircle, HelpCircle, Check, BookOpen } from 'lucide-react';

export default function Analyze() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState('ai'); // 'ai' or 'manual'
  const [step, setStep] = useState(1); // 1 = Upload/Input, 2 = Review, 3 = Result
  
  // AI upload state
  const [imageSrc, setImageSrc] = useState(null);
  const [base64Image, setBase64Image] = useState(null);
  const [fileName, setFileName] = useState('');
  
  // Analysis Form state (Manual or AI output)
  const [gender, setGender] = useState('Male');
  const [faceShape, setFaceShape] = useState('Oval');
  const [skinTone, setSkinTone] = useState('Medium');
  const [bodyType, setBodyType] = useState('Rectangle');
  const [sizeSuggestion, setSizeSuggestion] = useState('Medium (M)');
  const [stylePersonality, setStylePersonality] = useState('Classic Elegance');
  const [bestColor, setBestColor] = useState('Blue');

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const user = JSON.parse(localStorage.getItem('user') || '{}');

  // Handle Photo selection
  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;

    if (file.size > 4 * 1024 * 1024) {
      setError('Image too large. Please upload an image under 4 MB.');
      return;
    }

    setFileName(file.name);
    setError('');

    const reader = new FileReader();
    reader.onloadend = () => {
      setImageSrc(reader.result);
      setBase64Image(reader.result);
      setStep(2);
    };
    reader.readAsDataURL(file);
  };

  // Run AI Vision Analysis
  const runAiAnalysis = async () => {
    if (!base64Image) {
      setError('Please select an image first.');
      return;
    }

    setLoading(true);
    setError('');

    try {
      // 1. Analyze base64 image via Groq Llama 4 Vision Model
      const result = await groqService.analyzeFace(base64Image);
      
      // 2. Map Vision results to state variables
      if (result.gender) setGender(result.gender);
      if (result.face_shape) setFaceShape(result.face_shape);
      if (result.skin_tone) setSkinTone(result.skin_tone);
      if (result.body_type) setBodyType(result.body_type);
      if (result.size) setSizeSuggestion(result.size);
      if (result.style_personality) setStylePersonality(result.style_personality);
      
      // Select appropriate color based on skin tone and style
      const tone = (result.skin_tone || '').toLowerCase();
      let color = 'Blue';
      if (tone.includes('fair') || tone.includes('light')) color = 'Emerald';
      else if (tone.includes('dark') || tone.includes('deep')) color = 'Gold';
      else if (tone.includes('medium')) color = 'Indigo';
      setBestColor(color);

      // Save analysis to Flask database
      const saved = await apiService.saveAnalysis({
        user_id: user.id,
        gender: result.gender || 'Male',
        face_shape: result.face_shape || 'Oval',
        skin_tone: result.skin_tone || 'Medium',
        body_type: result.body_type || 'Rectangle',
        size_suggestion: result.size || 'Medium (M)',
        style_personality: result.style_personality || 'Classic Elegance',
        best_color: color
      });

      setStep(3);
    } catch (err) {
      console.error('Vision analysis error:', err);
      setError(err.message || 'AI Analysis failed. Make sure your Groq API key is valid in Settings or fallback to Manual selection.');
    } finally {
      setLoading(false);
    }
  };

  // Save manual styling parameters
  const handleSaveManual = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    
    try {
      await apiService.saveAnalysis({
        user_id: user.id,
        gender,
        face_shape: faceShape,
        skin_tone: skinTone,
        body_type: bodyType,
        size_suggestion: sizeSuggestion,
        style_personality: stylePersonality,
        best_color: bestColor
      });
      setStep(3);
    } catch (err) {
      console.error('Save manual analysis error:', err);
      setError('Failed to save manual settings. Please check your backend connection.');
    } finally {
      setLoading(false);
    }
  };

  const resetState = () => {
    setImageSrc(null);
    setBase64Image(null);
    setFileName('');
    setError('');
    setStep(1);
  };

  return (
    <div style={{ maxWidth: '800px', margin: '0 auto' }} className="animate-slide-up">
      {/* Title */}
      <div style={{ textAlign: 'left', marginBottom: '2rem' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.5rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Sparkles color="var(--primary)" />
          <span>Style Analysis</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)' }}>
          Create your styling profile using automated AI image analysis or manual configurations.
        </p>
      </div>

      {/* Tabs Menu (only at step 1) */}
      {step === 1 && (
        <div style={{ 
          display: 'flex', 
          borderBottom: '1px solid var(--border-color)', 
          marginBottom: '2rem', 
          gap: '1.5rem' 
        }}>
          <button 
            onClick={() => { setActiveTab('ai'); setError(''); }}
            style={{
              padding: '0.75rem 0.25rem',
              background: 'transparent',
              border: 'none',
              borderBottom: activeTab === 'ai' ? '2px solid var(--primary)' : '2px solid transparent',
              color: activeTab === 'ai' ? '#ffffff' : 'var(--text-secondary)',
              fontWeight: '600',
              cursor: 'pointer',
              fontSize: '1rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem'
            }}
          >
            <Upload size={16} />
            <span>AI Photo Analysis</span>
          </button>
          <button 
            onClick={() => { setActiveTab('manual'); setError(''); }}
            style={{
              padding: '0.75rem 0.25rem',
              background: 'transparent',
              border: 'none',
              borderBottom: activeTab === 'manual' ? '2px solid var(--primary)' : '2px solid transparent',
              color: activeTab === 'manual' ? '#ffffff' : 'var(--text-secondary)',
              fontWeight: '600',
              cursor: 'pointer',
              fontSize: '1rem',
              display: 'flex',
              alignItems: 'center',
              gap: '0.5rem'
            }}
          >
            <BookOpen size={16} />
            <span>Manual Profile Creator</span>
          </button>
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

      {/* Main Wizard Area */}
      <div className="glass-card" style={{ padding: '2.5rem 2rem' }}>
        
        {/* ================= STEP 1 ================= */}
        {step === 1 && activeTab === 'ai' && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1.5rem' }}>
            <div style={{
              width: '100%',
              maxHeight: '300px',
              border: '2px dashed var(--border-color)',
              borderRadius: '16px',
              padding: '3rem 2rem',
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              cursor: 'pointer',
              backgroundColor: 'rgba(255,255,255,0.01)',
              transition: 'all 0.2s ease',
              position: 'relative'
            }} className="upload-dropzone">
              <input 
                type="file" 
                accept="image/*" 
                onChange={handleFileChange}
                style={{
                  position: 'absolute',
                  top: 0,
                  left: 0,
                  width: '100%',
                  height: '100%',
                  opacity: 0,
                  cursor: 'pointer'
                }}
              />
              <Upload size={48} color="var(--text-muted)" style={{ marginBottom: '1rem' }} />
              <h3 style={{ fontSize: '1.15rem', marginBottom: '0.25rem' }}>Upload your photo</h3>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>Supports JPG, PNG (Max 4MB)</p>
            </div>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.25rem', marginTop: '0.5rem' }}>
              <HelpCircle size={14} />
              We analyze facial features and skin tone to determine your ultimate styling configuration.
            </p>
          </div>
        )}

        {step === 1 && activeTab === 'manual' && (
          <form onSubmit={handleSaveManual} style={{ display: 'flex', flexDirection: 'column', gap: '1.25rem' }}>
            <h3 style={{ fontSize: '1.25rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.5rem', textAlign: 'left', marginBottom: '1rem' }}>
              Enter Personal Dimensions
            </h3>
            
            <div className="grid-2">
              <div className="form-group">
                <label className="form-label" htmlFor="manual-gender">Gender</label>
                <select id="manual-gender" className="form-select" value={gender} onChange={(e) => setGender(e.target.value)}>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="manual-shape">Face Shape</label>
                <select id="manual-shape" className="form-select" value={faceShape} onChange={(e) => setFaceShape(e.target.value)}>
                  <option value="Oval">Oval</option>
                  <option value="Round">Round</option>
                  <option value="Square">Square</option>
                  <option value="Heart">Heart</option>
                  <option value="Oblong">Oblong</option>
                  <option value="Diamond">Diamond</option>
                </select>
              </div>
            </div>

            <div className="grid-2">
              <div className="form-group">
                <label className="form-label" htmlFor="manual-tone">Skin Tone</label>
                <select id="manual-tone" className="form-select" value={skinTone} onChange={(e) => setSkinTone(e.target.value)}>
                  <option value="Fair">Fair</option>
                  <option value="Light">Light</option>
                  <option value="Medium">Medium</option>
                  <option value="Dark">Dark</option>
                  <option value="Deep">Deep</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="manual-body">Body Type</label>
                <select id="manual-body" className="form-select" value={bodyType} onChange={(e) => setBodyType(e.target.value)}>
                  <option value="Rectangle">Rectangle</option>
                  <option value="Pear / A-Shape">Pear / A-Shape</option>
                  <option value="Inverted Triangle">Inverted Triangle</option>
                  <option value="Hourglass">Hourglass</option>
                  <option value="Oval / Apple">Oval / Apple</option>
                </select>
              </div>
            </div>

            <div className="grid-3">
              <div className="form-group">
                <label className="form-label" htmlFor="manual-size">Size Suggestion</label>
                <select id="manual-size" className="form-select" value={sizeSuggestion} onChange={(e) => setSizeSuggestion(e.target.value)}>
                  <option value="Small (S)">Small (S)</option>
                  <option value="Medium (M)">Medium (M)</option>
                  <option value="Large (L)">Large (L)</option>
                  <option value="Extra Large (XL)">Extra Large (XL)</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="manual-personality">Style Personality</label>
                <select id="manual-personality" className="form-select" value={stylePersonality} onChange={(e) => setStylePersonality(e.target.value)}>
                  <option value="Classic Elegance">Classic Elegance</option>
                  <option value="Urban Minimalist">Urban Minimalist</option>
                  <option value="Bohemian Rhapsody">Bohemian Rhapsody</option>
                  <option value="Sporty Casual">Sporty Casual</option>
                  <option value="Vintage Chic">Vintage Chic</option>
                </select>
              </div>

              <div className="form-group">
                <label className="form-label" htmlFor="manual-color">Best Color Pairing</label>
                <select id="manual-color" className="form-select" value={bestColor} onChange={(e) => setBestColor(e.target.value)}>
                  <option value="Blue">Blue</option>
                  <option value="Indigo">Indigo</option>
                  <option value="Emerald">Emerald</option>
                  <option value="Gold">Gold</option>
                  <option value="Ruby">Ruby</option>
                  <option value="Crimson">Crimson</option>
                </select>
              </div>
            </div>

            <button type="submit" className="btn btn-primary" style={{ alignSelf: 'flex-start', marginTop: '1rem' }} disabled={loading}>
              {loading ? <Loader className="spinner" size={14} /> : null}
              <span>Save Styling Profile</span>
            </button>
          </form>
        )}

        {/* ================= STEP 2 ================= */}
        {step === 2 && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '1.5rem' }}>
            <h3 style={{ fontSize: '1.25rem', marginBottom: '0.25rem' }}>Review Selected Photo</h3>
            
            <div style={{
              width: '100%',
              maxWidth: '300px',
              height: '300px',
              borderRadius: '16px',
              overflow: 'hidden',
              border: '1px solid var(--border-color)',
              boxShadow: 'var(--shadow-md)',
              position: 'relative'
            }}>
              <img src={imageSrc} alt="Preview" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
            </div>

            <div style={{ display: 'flex', gap: '1rem', width: '100%', justifyContent: 'center' }}>
              <button onClick={resetState} className="btn btn-outline" disabled={loading}>
                <RefreshCw size={16} />
                <span>Re-upload</span>
              </button>
              
              <button onClick={runAiAnalysis} className="btn btn-primary" disabled={loading}>
                {loading ? (
                  <>
                    <Loader size={16} className="spinner" style={{ animationDuration: '0.8s' }} />
                    <span>Analyzing Image...</span>
                  </>
                ) : (
                  <>
                    <Sparkles size={16} />
                    <span>Analyze Styling Profile</span>
                  </>
                )}
              </button>
            </div>
          </div>
        )}

        {/* ================= STEP 3 ================= */}
        {step === 3 && (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '2rem' }}>
            {/* Success icon */}
            <div style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              background: 'rgba(16, 185, 129, 0.15)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              border: '1px solid rgba(16, 185, 129, 0.4)',
              color: 'var(--success)'
            }}>
              <Check size={32} />
            </div>

            <div style={{ textAlign: 'center' }}>
              <h2 style={{ fontSize: '1.75rem', marginBottom: '0.25rem' }}>Analysis Completed!</h2>
              <p style={{ color: 'var(--text-secondary)' }}>Your styling configurations have been compiled and saved to the registry.</p>
            </div>

            {/* Compiled Results Card */}
            <div style={{
              width: '100%',
              maxWidth: '500px',
              background: 'var(--bg-tertiary)',
              padding: '1.75rem',
              borderRadius: '18px',
              border: '1px solid var(--border-color)',
              textAlign: 'left',
              display: 'flex',
              flexDirection: 'column',
              gap: '1.25rem'
            }}>
              <h4 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border-color)', paddingBottom: '0.5rem', marginBottom: 0 }}>
                Styling Profile Summary
              </h4>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem' }}>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Gender</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{gender}</div>
                </div>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Face Shape</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{faceShape}</div>
                </div>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Skin Tone</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{skinTone}</div>
                </div>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Body Type</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{bodyType}</div>
                </div>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Size Suggestion</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{sizeSuggestion}</div>
                </div>
                <div>
                  <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Style Persona</span>
                  <div style={{ fontSize: '1rem', fontWeight: '600', color: '#ffffff' }}>{stylePersonality}</div>
                </div>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderTop: '1px solid var(--border-color)', paddingTop: '1rem', marginTop: '0.5rem' }}>
                <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Best Matching Colors</span>
                <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                  <div style={{
                    width: '14px',
                    height: '14px',
                    borderRadius: '50%',
                    backgroundColor: bestColor.toLowerCase(),
                    border: '1px solid #ffffff'
                  }} />
                  <span style={{ fontWeight: '600', color: '#ffffff' }}>{bestColor}</span>
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '1rem' }}>
              <button onClick={resetState} className="btn btn-outline">
                <span>Run Another</span>
              </button>
              <button onClick={() => navigate('/')} className="btn btn-primary">
                <span>Go to Dashboard</span>
              </button>
            </div>
          </div>
        )}
      </div>
      <style>{`
        .upload-dropzone:hover {
          border-color: var(--primary) !important;
          background-color: rgba(99, 102, 241, 0.03) !important;
        }
      `}</style>
    </div>
  );
}
