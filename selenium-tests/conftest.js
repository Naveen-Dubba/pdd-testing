const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const fs = require('fs');
const path = require('path');
const config = require('./config');
const reporter = require('./reporter');

const globalResults = [];

// Helper functions for easy element retrieval & assertions
async function initDriver() {
  const options = new chrome.Options();
  config.CHROME_OPTIONS.forEach(opt => options.addArguments(opt));
  
  // Set headless mode for CI environments if specified
  if (process.env.HEADLESS === 'true') {
    options.addArguments('--headless');
  }

  const driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();

  await driver.manage().setTimeouts({ implicit: 10000 });
  return driver;
}

async function takeScreenshot(driver, name) {
  const screenshotsDir = path.join(__dirname, 'screenshots');
  if (!fs.existsSync(screenshotsDir)) {
    fs.mkdirSync(screenshotsDir, { recursive: true });
  }
  const filename = `${name.replace(/[^a-z0-9]/gi, '_').toLowerCase()}.png`;
  const filePath = path.join(screenshotsDir, filename);
  
  const image = await driver.takeScreenshot();
  fs.writeFileSync(filePath, image, 'base64');
  return path.relative(__dirname, filePath);
}

module.exports = {
  globalResults,
  initDriver,
  takeScreenshot,
  
  // Mocha hook integration
  mochaHooks: {
    afterAll: async function () {
      console.log('\nMocha afterAll: Compiling and generating Excel report...');
      await reporter.generateReport(globalResults);
    }
  }
};
