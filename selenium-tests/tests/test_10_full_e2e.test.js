const { expect } = require('chai');
const { initDriver, takeScreenshot, globalResults, ensureLoggedIn } = require('../conftest');
const { By, until } = require('selenium-webdriver');
const config = require('../config');

describe('Web Complete Application E2E Journeys', function () {
  let driver;
  const screen = 'Full E2E Flow';

  before(async function () {
    driver = await initDriver();
    await ensureLoggedIn(driver);
  });

  after(async function () {
    if (driver) {
      await driver.quit();
    }
  });

  async function recordResult(id, type, desc, fn) {
    const start = Date.now();
    try {
      await fn();
      globalResults.push({
        id, screen, type, description: desc, status: 'PASS', duration: Date.now() - start
      });
    } catch (err) {
      const screenshot = await takeScreenshot(driver, id);
      globalResults.push({
        id, screen, type, description: desc, status: 'FAIL', duration: Date.now() - start, error: err.message, screenshot
      });
      throw err;
    }
  }

  it('TC-E2E-01: Full user journey - Step 1: Login validation', async function () {
    await recordResult('TC-E2E-01', 'Functional', 'Verify E2E path starts with standard login validation', async () => {
      // Login was handled in before() via ensureLoggedIn — verify we are already on dashboard
      const url = await driver.getCurrentUrl();
      expect(url).to.contain('dashboard');
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Dashboard');
    });
  });

  it('TC-E2E-02: Full user journey - Step 2: Dashboard greeting rendering check', async function () {
    await recordResult('TC-E2E-02', 'UI/UX', 'Verify user details display greeting on main panel banner', async () => {
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Hello');
    });
  });

  it('TC-E2E-03: Full user journey - Step 3: Transition route to Style Chatbot', async function () {
    await recordResult('TC-E2E-03', 'Functional', 'Navigate to chatbot tab within the active session', async () => {
      const chatLink = await driver.findElement(By.xpath("//nav//a[contains(@href, 'chatbot') or contains(text(), 'Chat')]"));
      await chatLink.click();
      await driver.wait(until.urlContains('chatbot'), 5000);
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Style Chat');
    });
  });

  it('TC-E2E-04: Full user journey - Step 4: Submission of styling question', async function () {
    await recordResult('TC-E2E-04', 'Functional', 'Type and submit clothing coordinate query in active session', async () => {
      const input = await driver.findElement(By.xpath("//input[@placeholder='Ask Vastra...' or @type='text']"));
      await input.sendKeys('What matches dark blue jeans?');
      const btn = await driver.findElement(By.xpath("//button[@type='submit' or contains(@class, 'send')]"));
      await btn.click();
      const timeSleep = (ms) => new Promise(res => setTimeout(res, ms));
      await timeSleep(2000);
      const body = await driver.findElement(By.tagName('body')).getText();
      expect(body).to.contain('blue jeans');
    });
  });

  it('TC-E2E-05: Full user journey - Step 5: Transition route to Face Shape Analysis page', async function () {
    await recordResult('TC-E2E-05', 'Functional', 'Navigate to Face Shape Wizard within the active session', async () => {
      const analyzeLink = await driver.findElement(By.xpath("//nav//a[contains(@href, 'analyze') or contains(text(), 'Analyze')]"));
      await analyzeLink.click();
      await driver.wait(until.urlContains('analyze'), 5000);
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Face Shape');
    });
  });

  it('TC-E2E-06: Full user journey - Step 6: Step 1 Wizard check', async function () {
    await recordResult('TC-E2E-06', 'UI/UX', 'Confirm Image selection prompt renders correctly in E2E session', async () => {
      const stepper = await driver.findElement(By.xpath("//*[contains(text(), 'Step 1') or contains(text(), 'Upload')]"));
      expect(await stepper.isDisplayed()).to.be.true;
    });
  });

  it('TC-E2E-07: Full user journey - Step 7: Transition route to Profile metrics page', async function () {
    await recordResult('TC-E2E-07', 'Functional', 'Navigate to Profile dashboard in active session', async () => {
      const profileLink = await driver.findElement(By.xpath("//nav//a[contains(@href, 'profile') or contains(text(), 'Profile')]"));
      await profileLink.click();
      await driver.wait(until.urlContains('profile'), 5000);
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Profile');
    });
  });

  it('TC-E2E-08: Full user journey - Step 8: Profile verification matching details', async function () {
    await recordResult('TC-E2E-08', 'Functional', 'Verify that profile shows test email display in active session', async () => {
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain(config.TEST_EMAIL);
    });
  });

  it('TC-E2E-09: Full user journey - Step 9: Transition route to settings options', async function () {
    await recordResult('TC-E2E-09', 'Functional', 'Navigate to Settings panel in active session', async () => {
      const settingsLink = await driver.findElement(By.xpath("//a[contains(@href, 'settings') or contains(text(), 'Settings')]"));
      await settingsLink.click();
      await driver.wait(until.urlContains('settings'), 5000);
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Settings');
    });
  });

  it('TC-E2E-10: Full user journey - Step 10: Logout completion redirect', async function () {
    await recordResult('TC-E2E-10', 'Functional', 'Verify clean logout and redirection to Auth login screen', async () => {
      const logout = await driver.findElement(By.xpath("//*[contains(text(), 'Log out') or contains(text(), 'Logout')]"));
      await logout.click();
      await driver.wait(until.urlContains('login'), 8000);
      const text = await driver.findElement(By.tagName('body')).getText();
      expect(text).to.contain('Welcome Back');
      await takeScreenshot(driver, 'e2e_complete_logout');
    });
  });
});
