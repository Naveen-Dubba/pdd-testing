import React, { useState, useRef, useEffect } from 'react';
import { groqService } from '../services/groq';
import { Send, Sparkles, User, SendHorizonal, Loader, AlertCircle } from 'lucide-react';

export default function Chatbot() {
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: "Hello! I am Vastra AI, your personal fashion stylist. I'm here to help you coordinate outfits, suggest color pairings, advise on what to wear for weddings or parties, and give shopping suggestions. What are we styling today?"
    }
  ]);
  const [inputText, setInputText] = useState('');
  const [loading, setLoading] = useState(false);
  
  const chatEndRef = useRef(null);

  const quickPrompts = [
    "What should I wear to a wedding reception?",
    "Suggest colors that pair well with Olive Green",
    "Casual outfit ideas for a summer weekend trip",
    "Style recommendations for rectangle body type"
  ];

  const handleSend = async (textToSend) => {
    const text = textToSend || inputText;
    if (!text.trim() || loading) return;

    // Add user message
    const userMsg = { role: 'user', content: text };
    setMessages(prev => [...prev, userMsg]);
    setInputText('');
    setLoading(true);

    try {
      // Get conversation history to send (excluding first welcome msg)
      const historyToSend = messages
        .filter(m => m.role !== 'system')
        .map(m => ({ role: m.role, content: m.content }));

      const reply = await groqService.chatCompletion(historyToSend, text);
      
      setMessages(prev => [...prev, { role: 'assistant', content: reply }]);
    } catch (error) {
      console.error(error);
      setMessages(prev => [...prev, { 
        role: 'assistant', 
        content: "Oops! I encountered an error connecting to my servers. Please try again in a moment." 
      }]);
    } finally {
      setLoading(false);
    }
  };

  // Auto-scroll to bottom
  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, loading]);

  return (
    <div style={{
      maxWidth: '900px',
      margin: '0 auto',
      height: 'calc(100vh - 160px)',
      display: 'flex',
      flexDirection: 'column',
      gap: '1.5rem'
    }} className="animate-slide-up">
      {/* Title */}
      <div style={{ textAlign: 'left' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '0.25rem', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <Sparkles color="var(--primary)" />
          <span>AI Chat Stylist</span>
        </h1>
        <p style={{ color: 'var(--text-secondary)' }}>Get instant recommendations, color coordinates, and style options from your AI assistant.</p>
      </div>

      {/* Main Chat Workspace */}
      <div className="glass-card" style={{
        flexGrow: 1,
        display: 'flex',
        flexDirection: 'column',
        padding: '1.5rem',
        overflow: 'hidden',
        position: 'relative',
        borderRadius: '24px'
      }}>
        {/* Messages List */}
        <div style={{
          flexGrow: 1,
          overflowY: 'auto',
          display: 'flex',
          flexDirection: 'column',
          gap: '1.25rem',
          paddingRight: '0.5rem',
          marginBottom: '1rem'
        }}>
          {messages.map((msg, index) => {
            const isUser = msg.role === 'user';
            return (
              <div
                key={index}
                style={{
                  display: 'flex',
                  justifyContent: isUser ? 'flex-end' : 'flex-start',
                  alignItems: 'flex-start',
                  gap: '0.75rem',
                  maxWidth: '85%',
                  alignSelf: isUser ? 'flex-end' : 'flex-start'
                }}
              >
                {/* Profile Icon for Bot */}
                {!isUser && (
                  <div style={{
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    background: 'var(--primary-gradient)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#ffffff',
                    flexShrink: 0
                  }}>
                    <Sparkles size={14} />
                  </div>
                )}

                {/* Speech Bubble */}
                <div style={{
                  background: isUser ? 'var(--primary-gradient)' : 'var(--bg-tertiary)',
                  padding: '0.85rem 1.25rem',
                  borderRadius: isUser ? '20px 20px 4px 20px' : '4px 20px 20px 20px',
                  color: isUser ? '#ffffff' : 'var(--text-primary)',
                  fontSize: '0.95rem',
                  lineHeight: '1.5',
                  textAlign: 'left',
                  border: isUser ? '1px solid rgba(255,255,255,0.08)' : '1px solid var(--border-color)',
                  boxShadow: 'var(--shadow-sm)',
                  whiteSpace: 'pre-line'
                }}>
                  {msg.content}
                </div>

                {/* Profile Icon for User */}
                {isUser && (
                  <div style={{
                    width: '32px',
                    height: '32px',
                    borderRadius: '50%',
                    background: 'var(--secondary-gradient)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    color: '#ffffff',
                    flexShrink: 0
                  }}>
                    <User size={14} />
                  </div>
                )}
              </div>
            );
          })}
          
          {/* Thinking State */}
          {loading && (
            <div style={{ display: 'flex', justifyContent: 'flex-start', alignItems: 'center', gap: '0.75rem', alignSelf: 'flex-start' }}>
              <div style={{
                width: '32px',
                height: '32px',
                borderRadius: '50%',
                background: 'var(--primary-gradient)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                color: '#ffffff',
                flexShrink: 0
              }}>
                <Sparkles size={14} />
              </div>
              <div style={{
                background: 'var(--bg-tertiary)',
                padding: '0.85rem 1.25rem',
                borderRadius: '4px 20px 20px 20px',
                border: '1px solid var(--border-color)',
                display: 'flex',
                alignItems: 'center',
                gap: '0.5rem',
                color: 'var(--text-secondary)',
                fontSize: '0.9rem'
              }}>
                <Loader size={14} className="spinner" style={{ animationDuration: '0.8s' }} />
                <span>VASTRA AI is thinking...</span>
              </div>
            </div>
          )}
          <div ref={chatEndRef} />
        </div>

        {/* Quick Prompts Chips */}
        {messages.length === 1 && (
          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '0.5rem',
            textAlign: 'left',
            marginBottom: '1rem',
            animation: 'fadeIn 0.5s ease'
          }}>
            <span style={{ fontSize: '0.8rem', color: 'var(--text-muted)', fontWeight: '500', paddingLeft: '0.25rem' }}>
              Suggested prompts to get started:
            </span>
            <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
              {quickPrompts.map((p, idx) => (
                <button
                  key={idx}
                  onClick={() => handleSend(p)}
                  className="quick-chip"
                  style={{
                    padding: '0.45rem 0.9rem',
                    background: 'rgba(255, 255, 255, 0.03)',
                    border: '1px solid var(--border-color)',
                    color: 'var(--text-secondary)',
                    borderRadius: '12px',
                    fontSize: '0.825rem',
                    cursor: 'pointer',
                    transition: 'all 0.2s ease',
                    textAlign: 'left'
                  }}
                >
                  {p}
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Input Bar */}
        <div style={{
          display: 'flex',
          gap: '0.75rem',
          borderTop: '1px solid var(--border-color)',
          paddingTop: '1rem'
        }}>
          <input
            type="text"
            className="form-input"
            placeholder="Type your styling question here..."
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => { if (e.key === 'Enter') handleSend(); }}
            disabled={loading}
            style={{ borderRadius: '16px', flexGrow: 1 }}
          />
          <button
            onClick={() => handleSend()}
            className="btn btn-primary"
            style={{
              padding: '0 1.25rem',
              borderRadius: '16px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              flexShrink: 0
            }}
            disabled={loading || !inputText.trim()}
          >
            <Send size={16} />
          </button>
        </div>
      </div>
      <style>{`
        .quick-chip:hover {
          background-color: rgba(99, 102, 241, 0.1) !important;
          border-color: rgba(99, 102, 241, 0.3) !important;
          color: #ffffff !important;
          transform: translateY(-1px);
        }
      `}</style>
    </div>
  );
}
