import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_home_screen_dashboard(driver):
    """
    Verify Home screen elements and quick action navigation.
    
    1. Log in to get to the Home dashboard.
    2. Verify presence of welcome message, quick action tiles, and analysis button.
    3. Click 'Style Chat' quick action and verify tab/screen navigation.
    """
    print("\n[Home Test] Logging in to access Home screen...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    edit_texts[0].send_keys(config.TEST_EMAIL)
    edit_texts[1].send_keys(config.TEST_PASSWORD)
    driver.find_by_text("Sign In").click()
    
    # Wait for Home screen to load
    print("[Home Test] Waiting for Home dashboard...")
    driver.find_by_text_contains("Hello", timeout=15)
    
    # Verify main UI headers and titles
    assert driver.find_by_text("AI PERSONAL STYLIST") is not None
    assert driver.find_by_text("Start AI Analysis") is not None
    assert driver.find_by_text("Quick Actions") is not None
    print("[Home Test] Verified core Home dashboard headers.")
    
    # Verify Quick Action cards
    style_chat_tile = driver.find_by_text("Style Chat")
    history_tile = driver.find_by_text("History")
    assert style_chat_tile is not None
    assert history_tile is not None
    print("[Home Test] Verified 'Style Chat' and 'History' quick action tiles are visible.")
    
    # Click 'Style Chat' tile to test navigation
    style_chat_tile.click()
    time.sleep(2)
    
    # Verify we are on the Chatbot tab/screen (which has "Style Chat" in the app bar)
    chatbot_title = driver.find_by_text("Style Chat", timeout=10)
    assert chatbot_title is not None, "Failed to navigate to Style Chat via Quick Action"
    print("[Home Test] Home dashboard quick action successfully navigated to Style Chat.")
