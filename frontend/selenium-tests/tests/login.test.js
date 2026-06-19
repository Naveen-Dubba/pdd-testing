const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const assert = require('assert');

describe('AI Vastra E2E Login Test', function () {
  this.timeout(30000); // 30 seconds timeout for E2E
  let driver;

  // Pre-register test user so the DB is populated in fresh environments (e.g. CI)
  before(async () => {
    try {
      const response = await fetch('http://localhost:5000/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: "Test User",
          email: "test@example.com",
          password: "password123",
          gender: "Male",
          age: 25
        })
      });
      if (response.status === 201) {
        console.log('   [Setup] Registered E2E test user successfully');
      } else if (response.status === 409) {
        console.log('   [Setup] Test user already registered');
      } else {
        console.log(`   [Setup] Pre-registration status: ${response.status}`);
      }
    } catch (err) {
      console.warn('   [Setup] Warning: Could not reach Flask backend for pre-registration:', err.message);
    }
  });

  beforeEach(async () => {
    const options = new chrome.Options();
    
    // Check if HEADLESS env variable is set to run in CI environment
    if (process.env.HEADLESS === 'true') {
      options.addArguments('--headless=new');
      options.addArguments('--disable-gpu');
      options.addArguments('--no-sandbox');
      options.addArguments('--disable-dev-shm-usage');
    }

    driver = await new Builder()
      .forBrowser('chrome')
      .setChromeOptions(options)
      .build();
  });

  afterEach(async () => {
    if (driver) {
      await driver.quit();
    }
  });

  it('should successfully log in and redirect to dashboard', async () => {
    // 1. Navigate to the local dev login hash route
    await driver.get('http://localhost:5173/#/login');

    // 2. Wait for the email input element to load
    const emailInput = await driver.wait(
      until.elementLocated(By.id('email')),
      10000,
      'Email input field not found on login page'
    );

    // 3. Fill email and password fields
    const passwordInput = await driver.findElement(By.id('password'));
    const loginButton = await driver.findElement(By.id('login-button'));

    await emailInput.clear();
    await emailInput.sendKeys('test@example.com');
    await passwordInput.clear();
    await passwordInput.sendKeys('password123');

    // 4. Click the login button
    await loginButton.click();

    // 5. Wait for the URL to change to the dashboard (i.e. redirects to home screen /)
    await driver.wait(
      async () => {
        const currentUrl = await driver.getCurrentUrl();
        return currentUrl.endsWith('#/') || currentUrl.includes('/#/home') || !currentUrl.includes('login');
      },
      15000,
      'Redirect to dashboard timed out after login'
    );

    // 6. Verify that user details exist in local storage to confirm login state
    const userStorage = await driver.executeScript("return localStorage.getItem('user');");
    assert.ok(userStorage, 'User object should be stored in localStorage upon login');
    
    const parsedUser = JSON.parse(userStorage);
    assert.strictEqual(parsedUser.email, 'test@example.com', 'Local storage user email should match the logged-in email');
  });
});
