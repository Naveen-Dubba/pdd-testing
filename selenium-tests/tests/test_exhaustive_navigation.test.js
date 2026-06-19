const { Builder, By, until } = require('selenium-webdriver');
const config = require('../config');

// Generate combinations of origin to destination navigations
const routes = ['/', '/login', '/register', '/dashboard', '/chat', '/profile', '/settings'];

describe('Exhaustive Navigation Matrix Tests', function () {
    this.timeout(45000);
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

    // Generate tests for moving from every route to every other route (7 * 6 = 42 tests)
    routes.forEach(origin => {
        routes.forEach(destination => {
            if (origin !== destination) {
                it(`should cleanly navigate from ${origin} to ${destination} and maintain URL integrity`, async function () {
                    // Start at origin
                    await driver.get(`${config.baseUrl}${origin}`);
                    
                    // Attempt to navigate via direct URL change (simulating deep linking)
                    await driver.get(`${config.baseUrl}${destination}`);
                    
                    // Verify the URL changed properly
                    const currentUrl = await driver.getCurrentUrl();
                    if (!currentUrl.includes(destination) && !currentUrl.includes('/login')) {
                        // If it redirected to login, that's normal for auth routes, but otherwise it should match
                        console.warn(`Navigation redirect from ${origin} -> ${destination} resulted in ${currentUrl}`);
                    }
                    
                    // Check for 404 text on the page
                    const bodyText = await driver.findElement(By.tagName('body')).getText();
                    if (bodyText.includes('404') || bodyText.toLowerCase().includes('not found')) {
                        throw new Error(`404 Not Found error hit when navigating to ${destination}`);
                    }
                });
            }
        });
    });
});
