import React from 'react';
import { Navigate } from 'react-router-dom';

export default function RequireAuth({ children }) {
  const user = localStorage.getItem('user');

  if (!user) {
    // User is not logged in, redirect to login
    return <Navigate to="/login" replace />;
  }

  return children;
}
