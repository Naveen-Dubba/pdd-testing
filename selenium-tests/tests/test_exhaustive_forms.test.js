const { Builder, By, until } = require('selenium-webdriver');
const config = require('../config');

// Array of diverse test payloads spanning valid, boundary, and invalid inputs
const testInputs = [
    '',                             // Empty
    'A',                            // Single char
    'John Doe',                     // Standard string
    'test@example.com',             // Standard email
    'invalid-email',                // Invalid email format
    '1234567890',                   // Numbers
    '!@#$%^&*()',                   // Special characters
    'a'.repeat(255),                // Max length boundary
    '<script>alert("XSS")</script>' // Potential XSS string
];

// Target input field identifiers to locate and test
const fieldSelectors = [
    { type: 'css', selector: 'input[type="email"]' },
    { type: 'css', selector: 'input[type="password"]' },
    { type: 'css', selector: 'input[type="text"]' },
    { type: 'css', selector: 'textarea' }
];

// Forms usually exist on Login, Register, Profile, Chat
const formRoutes = ['/login', '/register', '/chat'];

describe('Exhaustive Form Input Validation Matrix', function () {
    this.timeout(60000);
    let driver;

    before(async function () {
        driver = await new Builder().forBrowser('chrome').build();
        await driver.manage().window().maximize();
    });

    after(async function () {
        if (driver) {
            await driver.quit();
        }
    });

    formRoutes.forEach(route => {
        fieldSelectors.forEach(field => {
            testInputs.forEach((inputVal, index) => {
                it(`should handle input variant ${index} for ${field.selector} on ${route}`, async function () {
                    try {
                        await driver.get(`${config.baseUrl}${route}`);
                        // Wait a tiny bit for render
                        await driver.sleep(500);
                        
                        const elements = await driver.findElements(By.css(field.selector));
                        if (elements.length > 0) {
                            const el = elements[0];
                            if (await el.isDisplayed() && await el.isEnabled()) {
                                // Clear and send keys
                                await el.clear();
                                await el.sendKeys(inputVal);
                                
                                // Verify it took the input without hard crashing the page
                                const value = await el.getAttribute('value');
                                // React/Vite might prevent XSS strings from staying as-is, but the page shouldn't crash
                                const bodyText = await driver.findElement(By.tagName('body')).getText();
                                if (bodyText.includes('Cannot GET') || bodyText.includes('Error')) {
                                    throw new Error(`Input "${inputVal}" caused a crash on ${route}`);
                                }
                            }
                        }
                    } catch (error) {
                        if (error.name !== 'NoSuchElementError') {
                            throw error;
                        }
                    }
                });
            });
        });
    });
});
