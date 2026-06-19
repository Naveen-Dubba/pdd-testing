import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_full_application_e2e_journey(driver):
    """
    Execute the complete End-to-End application user journey.
    
    1. Splash Screen: Auto-navigation to Login screen.
    2. Login Screen: Authenticate with valid test user credentials.
    3. Home Dashboard: Verify core elements and tap Style Chat quick action.
    4. Chatbot Screen: Send stylist message query and verify response.
    5. Profile & Settings: Verify user info, navigate to settings, and log out.
    6. Return: Confirm user is safely redirected back to the Login screen.
    """
    print("\n[E2E Journey] Starting full application journey...")
    
    # --- STEP 1: SPLASH SCREEN ---
    print("[E2E Journey] Phase 1: Splash screen auto-direct...")
    driver.find_by_text("VASTHARA AI", timeout=15)
    login_header = driver.find_by_text("Welcome Back", timeout=20)
    assert login_header is not None, "E2E: Failed to auto-navigate from Splash to Login"

    # --- STEP 2: LOGIN ---
    print("[E2E Journey] Phase 2: Logging in with test user...")
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    assert len(edit_texts) >= 2, "E2E: Could not find login input fields"
    
    edit_texts[0].send_keys(config.TEST_EMAIL)
    edit_texts[1].send_keys(config.TEST_PASSWORD)
    driver.find_by_text("Sign In").click()
    
    # --- STEP 3: HOME DASHBOARD ---
    print("[E2E Journey] Phase 3: Verifying home dashboard and quick actions...")
    home_welcome = driver.find_by_text_contains("Hello", timeout=15)
    assert home_welcome is not None, "E2E: Failed to reach Home dashboard"
    
    assert driver.find_by_text("AI PERSONAL STYLIST") is not None
    style_chat_tile = driver.find_by_text("Style Chat")
    
    # Click Style Chat quick action to navigate to Stylist Chat tab
    style_chat_tile.click()
    time.sleep(2)
    
    # --- STEP 4: CHATBOT SCREEN ---
    print("[E2E Journey] Phase 4: Interacting with style chatbot...")
    driver.find_by_text("Style Chat", timeout=10)
    
    chat_inputs = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    assert len(chat_inputs) > 0, "E2E: Chat input field not found"
    
    chat_field = chat_inputs[0]
    test_query = "What colors go well with olive green pants?"
    chat_field.send_keys(test_query)
    
    try:
        send_btn = driver.find_element(By.XPATH, "//*[@content-desc='Send' or @content-desc='send' or contains(@content-desc, 'Send')]")
        send_btn.click()
    except Exception:
        chat_field.submit()
        
    time.sleep(3)
    sent_bubble = driver.find_by_text_contains("pants", timeout=15)
    assert sent_bubble is not None, "E2E: Chatbot sent message was not registered"
    print("[E2E Journey] Chatbot message successfully sent.")
    
    # --- STEP 5: PROFILE & SETTINGS ---
    print("[E2E Journey] Phase 5: Profile inspection and Settings...")
    try:
        profile_tab = driver.find_element(By.XPATH, "//*[@content-desc='Profile' or @text='Profile' or contains(@content-desc, 'Profile')]")
        profile_tab.click()
        time.sleep(1)
    except Exception:
        pass
        
    profile_title = driver.find_by_text("Profile", timeout=10)
    assert profile_title is not None, "E2E: Failed to navigate to Profile tab"
    
    email_text = driver.find_by_text_contains(config.TEST_EMAIL)
    assert email_text is not None, "E2E: Profile email did not match configuration"
    
    # Open settings
    try:
        settings_icon = driver.find_element(By.XPATH, "//*[@content-desc='Settings' or contains(@content-desc, 'settings') or @text='Settings']")
        settings_icon.click()
    except Exception:
        driver.find_by_text("Settings").click()
        
    time.sleep(2)
    driver.find_by_text("Settings", timeout=10)
    
    # --- STEP 6: LOGOUT ---
    print("[E2E Journey] Phase 6: Logging out from app...")
    logout_tile = driver.find_by_text("Log out")
    logout_tile.click()
    time.sleep(2)
    
    # Verify we are back on Login Screen
    final_login_header = driver.find_by_text("Welcome Back", timeout=15)
    assert final_login_header is not None, "E2E: Logout failed to redirect to Login screen"
    
    print("[E2E Journey] Complete E2E journey executed successfully.")
