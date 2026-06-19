import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_settings_and_logout_flow(driver):
    """
    Verify Settings navigation and Logout functionality.
    
    1. Log in and navigate to Profile Screen.
    2. Tap Settings icon to open the Settings screen.
    3. Verify various settings tiles are present (Account, History, Logout, etc.).
    4. Click 'Log out' and verify redirection to the Login Screen.
    """
    print("\n[Settings Test] Logging in...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    edit_texts[0].send_keys(config.TEST_EMAIL)
    edit_texts[1].send_keys(config.TEST_PASSWORD)
    driver.find_by_text("Sign In").click()
    
    driver.find_by_text_contains("Hello", timeout=15)
    
    # Go to Profile tab
    print("[Settings Test] Navigating to Profile...")
    try:
        profile_tab = driver.find_element(By.XPATH, "//*[@content-desc='Profile' or @text='Profile' or contains(@content-desc, 'Profile')]")
        profile_tab.click()
        time.sleep(1)
    except Exception:
        pass
        
    # Open settings using Settings icon in AppBar (usually has content-desc "Settings" or gear icon)
    print("[Settings Test] Opening Settings...")
    try:
        settings_icon = driver.find_element(By.XPATH, "//*[@content-desc='Settings' or contains(@content-desc, 'settings') or @text='Settings']")
        settings_icon.click()
    except Exception:
        # If not found directly, look for any settings action or tap top right
        print("[Settings Test] Settings gear icon not found directly, attempting fallback click...")
        # Fallback: some apps have "Settings" text
        settings_label = driver.find_by_text("Settings")
        settings_label.click()
        
    time.sleep(2)
    
    # Assert Settings page load
    driver.find_by_text("Settings", timeout=10)
    
    # Assert settings options
    assert driver.find_by_text("Account") is not None
    assert driver.find_by_text("About") is not None
    
    logout_tile = driver.find_by_text("Log out")
    assert logout_tile is not None
    print("[Settings Test] Verified Settings screen and 'Log out' option.")
    
    # Trigger Logout
    print("[Settings Test] Tapping Log out...")
    logout_tile.click()
    time.sleep(2)
    
    # Verify redirected back to Login screen
    login_screen_header = driver.find_by_text("Welcome Back", timeout=15)
    assert login_screen_header is not None, "Failed to return to Login screen after logging out"
    print("[Settings Test] Logout successful and redirected to Login screen.")
