module.exports = {
  BASE_URL: 'http://localhost:5173', // Local Vite React port
  BACKEND_URL: 'http://localhost:5000', // Flask backend
  TEST_EMAIL: 'test@selenium.com',
  TEST_PASSWORD: 'Password123!',
  TEST_NAME: 'Selenium Web Tester',
  CHROME_OPTIONS: [
    '--start-maximized',
    '--disable-gpu',
    '--no-sandbox',
    '--disable-dev-shm-usage'
  ]
};
