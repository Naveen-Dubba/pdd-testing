import { useState } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { 
  Sparkles, 
  LayoutDashboard, 
  History, 
  MessageSquare, 
  User, 
  Settings, 
  LogOut, 
  Menu, 
  X,
  Shirt
} from 'lucide-react';

export default function Layout({ children }) {
  const navigate = useNavigate();
  const location = useLocation();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  
  const userJson = localStorage.getItem('user');
  const user = userJson ? JSON.parse(userJson) : { name: 'Guest', email: '' };

  const menuItems = [
    { name: 'Dashboard', path: '/dashboard', icon: LayoutDashboard },
    { name: 'Style Analysis', path: '/analyze', icon: Sparkles },
    { name: 'AI Chat Stylist', path: '/chatbot', icon: MessageSquare },
    { name: 'Styling History', path: '/history', icon: History },
    { name: 'Profile', path: '/profile', icon: User },
    { name: 'Settings', path: '/settings', icon: Settings },
  ];

  const handleLogout = () => {
    localStorage.removeItem('user');
    navigate('/login');
  };

  const isActive = (path) => {
    return location.pathname === path;
  };

  return (
    <div className="layout-container" style={{ display: 'flex', minHeight: '100vh', background: 'var(--bg-primary)' }}>
      {/* Sidebar - Desktop */}
      <aside className="sidebar glass" style={{
        width: '260px',
        display: 'flex',
        flexDirection: 'column',
        borderRight: '1px solid var(--border-color)',
        padding: '1.5rem',
        position: 'fixed',
        top: 0,
        bottom: 0,
        left: 0,
        zIndex: 100,
        backgroundColor: 'rgba(10, 11, 16, 0.9)'
      }}>
        {/* Logo */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', marginBottom: '2.5rem', paddingLeft: '0.5rem' }}>
          <div style={{
            background: 'var(--primary-gradient)',
            padding: '0.6rem',
            borderRadius: '12px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: 'var(--shadow-glow)'
          }}>
            <Shirt size={22} color="#ffffff" />
          </div>
          <span style={{
            fontFamily: 'var(--font-display)',
            fontWeight: 800,
            fontSize: '1.4rem',
            letterSpacing: '0.05em',
            background: 'linear-gradient(to right, #ffffff, #a5b4fc)',
            WebkitBackgroundClip: 'text',
            WebkitTextFillColor: 'transparent'
          }}>AI VASTRA</span>
        </div>

        {/* Navigation */}
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', flexGrow: 1 }}>
          {menuItems.map((item) => {
            const Icon = item.icon;
            const active = isActive(item.path);
            return (
              <Link
                key={item.name}
                to={item.path}
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '0.85rem',
                  padding: '0.8rem 1rem',
                  borderRadius: '12px',
                  color: active ? '#ffffff' : 'var(--text-secondary)',
                  background: active ? 'var(--primary-gradient)' : 'transparent',
                  fontWeight: active ? '600' : '500',
                  boxShadow: active ? '0 4px 12px rgba(99, 102, 241, 0.3)' : 'none',
                  transition: 'all 0.2s ease',
                  border: active ? '1px solid rgba(255, 255, 255, 0.1)' : '1px solid transparent'
                }}
                className={!active ? 'nav-item-hover' : ''}
              >
                <Icon size={18} />
                <span>{item.name}</span>
              </Link>
            );
          })}
        </nav>

        {/* User profile & Logout */}
        <div style={{ 
          marginTop: 'auto', 
          borderTop: '1px solid var(--border-color)', 
          paddingTop: '1.25rem',
          display: 'flex',
          flexDirection: 'column',
          gap: '1rem'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
            <div style={{
              width: '40px',
              height: '40px',
              borderRadius: '50%',
              background: 'var(--secondary-gradient)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontWeight: '700',
              fontFamily: 'var(--font-display)',
              color: '#ffffff',
              fontSize: '1.1rem'
            }}>
              {user.name.charAt(0).toUpperCase()}
            </div>
            <div style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
              <div style={{ fontWeight: '600', fontSize: '0.9rem', color: '#ffffff' }}>{user.name}</div>
              <div style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{user.email}</div>
            </div>
          </div>
          <button 
            onClick={handleLogout}
            className="btn btn-danger btn-sm" 
            style={{ width: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}
          >
            <LogOut size={14} />
            <span>Log out</span>
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div style={{ 
        flexGrow: 1, 
        marginLeft: '260px', 
        display: 'flex', 
        flexDirection: 'column',
        minHeight: '100vh',
        width: 'calc(100% - 260px)'
      }} className="main-layout-wrapper">
        {/* Header - Mobile & Desktop Bar */}
        <header className="glass" style={{
          height: '70px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          padding: '0 2rem',
          borderBottom: '1px solid var(--border-color)',
          position: 'sticky',
          top: 0,
          zIndex: 90,
          backgroundColor: 'rgba(10, 11, 16, 0.8)'
        }}>
          {/* Mobile Menu Trigger */}
          <button 
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            style={{
              display: 'none',
              background: 'transparent',
              border: 'none',
              color: '#ffffff',
              cursor: 'pointer',
            }}
            className="mobile-menu-btn"
          >
            {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>

          <div className="header-title" style={{ fontWeight: '600', fontSize: '1.1rem', color: 'var(--text-secondary)' }}>
            Welcome to the future of styling.
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <span className="badge badge-purple" style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
              <Sparkles size={12} />
              AI Powered
            </span>
          </div>
        </header>

        {/* Dynamic Mobile Menu */}
        {mobileMenuOpen && (
          <div className="glass animate-fade-in" style={{
            position: 'fixed',
            top: '70px',
            left: 0,
            right: 0,
            bottom: 0,
            zIndex: 95,
            backgroundColor: 'var(--bg-primary)',
            padding: '2rem',
            display: 'flex',
            flexDirection: 'column',
            gap: '1rem'
          }}>
            {menuItems.map((item) => {
              const Icon = item.icon;
              const active = isActive(item.path);
              return (
                <Link
                  key={item.name}
                  to={item.path}
                  onClick={() => setMobileMenuOpen(false)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '1rem',
                    padding: '1rem',
                    borderRadius: '12px',
                    color: active ? '#ffffff' : 'var(--text-secondary)',
                    background: active ? 'var(--primary-gradient)' : 'rgba(255,255,255,0.02)',
                    fontWeight: active ? '600' : '500',
                  }}
                >
                  <Icon size={20} />
                  <span>{item.name}</span>
                </Link>
              );
            })}
            <button 
              onClick={() => { setMobileMenuOpen(false); handleLogout(); }}
              className="btn btn-danger" 
              style={{ marginTop: 'auto', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '0.5rem' }}
            >
              <LogOut size={16} />
              <span>Log out</span>
            </button>
          </div>
        )}

        {/* Page Content */}
        <main style={{ flexGrow: 1, padding: '2rem', maxWidth: '1200px', width: '100%', margin: '0 auto' }}>
          {children}
        </main>
      </div>

      {/* Responsive adjustments CSS */}
      <style>{`
        .nav-item-hover:hover {
          color: #ffffff !important;
          background-color: rgba(255, 255, 255, 0.04) !important;
          transform: translateX(4px);
        }
        @media (max-width: 768px) {
          .sidebar {
            display: none !important;
          }
          .main-layout-wrapper {
            margin-left: 0 !important;
            width: 100% !important;
          }
          .mobile-menu-btn {
            display: block !important;
          }
        }
      `}</style>
    </div>
  );
}
