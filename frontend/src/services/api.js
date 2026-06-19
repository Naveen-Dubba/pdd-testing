const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000';

async function request(endpoint, options = {}) {
  const url = `${API_BASE_URL}${endpoint}`;
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  const config = {
    ...options,
    headers,
  };

  try {
    const response = await fetch(url, config);
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || `HTTP error! Status: ${response.status}`);
    }
    
    return data;
  } catch (error) {
    console.error(`API Request failed on ${endpoint}:`, error);
    throw error;
  }
}

export const apiService = {
  // Authentication
  async register(name, email, password, gender, age) {
    return request('/register', {
      method: 'POST',
      body: JSON.stringify({ name, email, password, gender, age: age ? parseInt(age) : null }),
    });
  },

  async login(email, password) {
    return request('/login', {
      method: 'POST',
      body: JSON.stringify({ email, password }),
    });
  },

  async getCurrentUser() {
    return request('/get_current_user', {
      method: 'GET',
    });
  },

  async logout() {
    return request('/logout', {
      method: 'POST',
    });
  },

  // Profile Update
  async updateProfile(name, email, gender, age) {
    return request('/user/update', {
      method: 'PUT',
      body: JSON.stringify({ name, email, gender, age: age ? parseInt(age) : null }),
    });
  },

  // Styling Analysis History
  async saveAnalysis(analysisData) {
    // analysisData: { user_id, gender, face_shape, skin_tone, body_type, size_suggestion, style_personality, best_color }
    return request('/analysis', {
      method: 'POST',
      body: JSON.stringify(analysisData),
    });
  },

  async getAnalyses(userId) {
    return request(`/analysis/${userId}`, {
      method: 'GET',
    });
  },

  async deleteAnalysis(analysisId) {
    return request(`/analysis/${analysisId}`, {
      method: 'DELETE',
    });
  },

  async clearAnalyses(userId) {
    return request(`/analysis/clear/${userId}`, {
      method: 'DELETE',
    });
  },

  // Dashboard Stats
  async getDashboard(userId) {
    return request(`/dashboard/${userId}`, {
      method: 'GET',
    });
  }
};
