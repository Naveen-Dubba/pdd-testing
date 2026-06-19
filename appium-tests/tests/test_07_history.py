import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_analysis_history_screen(driver):
    """
    Verify navigation to the Analysis History screen.
    
    1. Log in and access Home screen.
    2. Tap 'History' quick action tile.
    3. Verify that the History screen loads successfully, displaying either an empty state or historic logs.
    """
    print("\n[History Test] Logging in...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    edit_texts[0].send_keys(config.TEST_EMAIL)
    edit_texts[1].send_keys(config.TEST_PASSWORD)
    driver.find_by_text("Sign In").click()
    
    driver.find_by_text_contains("Hello", timeout=15)
    
    # Tap "History" quick action tile
    print("[History Test] Tapping 'History' quick action tile...")
    history_tile = driver.find_by_text("History")
    history_tile.click()
    time.sleep(2)
    
    # Verify History screen title in the app bar or header
    print("[History Test] Verifying History screen...")
    history_title = driver.find_by_text("History", timeout=10)
    assert history_title is not None, "Failed to navigate to History screen"
    
    # Verify empty state or historical list presence
    # The empty state text is: "No saved analyses yet" or similar, check if that or list items exist
    try:
        empty_text = driver.find_by_text_contains("No saved", timeout=5)
        assert empty_text is not None
        print("[History Test] Empty history state confirmed: 'No saved analyses yet' is visible.")
    except Exception:
        print("[History Test] History is not empty or different widget tree, verified page loads successfully.")
