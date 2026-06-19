import React from 'react';
import { HashRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import RequireAuth from './components/RequireAuth';
import Login from './screens/Login';
import Register from './screens/Register';
import Dashboard from './screens/Dashboard';
import Analyze from './screens/Analyze';
import Chatbot from './screens/Chatbot';
import History from './screens/History';
import Profile from './screens/Profile';
import Settings from './screens/Settings';

export default function App() {
  return (
    <Router>
      <Routes>
        {/* Public Auth Routes */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        {/* Protected Feature Routes (Wrapped in Layout & RequireAuth) */}
        <Route path="/" element={
          <RequireAuth>
            <Layout>
              <Dashboard />
            </Layout>
          </RequireAuth>
        } />

        <Route path="/dashboard" element={
          <RequireAuth>
            <Layout>
              <Dashboard />
            </Layout>
          </RequireAuth>
        } />


        <Route path="/analyze" element={
          <RequireAuth>
            <Layout>
              <Analyze />
            </Layout>
          </RequireAuth>
        } />

        <Route path="/chatbot" element={
          <RequireAuth>
            <Layout>
              <Chatbot />
            </Layout>
          </RequireAuth>
        } />

        <Route path="/history" element={
          <RequireAuth>
            <Layout>
              <History />
            </Layout>
          </RequireAuth>
        } />

        <Route path="/profile" element={
          <RequireAuth>
            <Layout>
              <Profile />
            </Layout>
          </RequireAuth>
        } />

        <Route path="/settings" element={
          <RequireAuth>
            <Layout>
              <Settings />
            </Layout>
          </RequireAuth>
        } />
      </Routes>
    </Router>
  );
}
