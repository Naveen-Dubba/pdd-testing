import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy

def test_splash_screen_logo_and_navigation(driver):
    """
    Verify Splash Screen loading and auto-navigation to Login.
    
    This test verifies that the 'VASTHARA AI' title is initially visible,
    and then after a short delay, the app automatically transitions to the Login page.
    """
    print("\n[Splash Test] Waiting for Splash screen to launch...")
    
    # 1. Assert Splash text is visible on launch (within timeout)
    splash_text = driver.find_by_text("VASTHARA AI", timeout=15)
    assert splash_text is not None, "Splash screen title 'VASTHARA AI' was not displayed"
    print("[Splash Test] Found 'VASTHARA AI' logo text.")

    # 2. Wait for auto-navigation to Login screen (detect "Welcome Back" or "Sign In" text)
    print("[Splash Test] Waiting for auto-redirect to Login screen...")
    login_header = driver.find_by_text("Welcome Back", timeout=20)
    assert login_header is not None, "Auto-navigation to Login screen failed"
    
    # Verify other login elements are visible to confirm redirect
    assert driver.find_by_text("Email Address") is not None
    assert driver.find_by_text("Password") is not None
    print("[Splash Test] Splash screen successfully auto-navigated to Login screen.")
