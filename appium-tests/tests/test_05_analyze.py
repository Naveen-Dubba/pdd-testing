import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_analyze_screen_navigation(driver):
    """
    Verify navigation to the Analyze / Face Capture screen.
    
    1. Log in and access Home screen.
    2. Tap 'Start AI Analysis' button on the dashboard.
    3. Verify redirection to the Capture / Analyze screen.
    """
    print("\n[Analyze Test] Logging in...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    edit_texts[0].send_keys(config.TEST_EMAIL)
    edit_texts[1].send_keys(config.TEST_PASSWORD)
    driver.find_by_text("Sign In").click()
    
    # Wait for Home
    driver.find_by_text_contains("Hello", timeout=15)
    
    # Click "Start AI Analysis" button
    print("[Analyze Test] Tapping 'Start AI Analysis' button...")
    analyze_btn = driver.find_by_text("Start AI Analysis")
    analyze_btn.click()
    time.sleep(2)
    
    # Verify we are on the Capture / Analyze Screen
    # The Capture screen has instructions or camera controls, e.g. "Position your face" or "Analyze Your Face"
    print("[Analyze Test] Verifying Analyze screen loaded...")
    capture_title = driver.find_by_text_contains("Analyze Your Face", timeout=10)
    assert capture_title is not None, "Failed to navigate to Analyze / Capture screen"
    
    print("[Analyze Test] Successfully verified Analyze / Capture screen navigation.")
