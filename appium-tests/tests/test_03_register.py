import time
import pytest
from selenium.webdriver.common.by import By
import config

def test_registration_flow(driver):
    """
    Verify the user registration flow.
    
    1. Navigate from Login to Register screen.
    2. Fill out Name, unique Email, Password, Age, and select Gender.
    3. Click 'Create Account' and verify redirection to Home or Login.
    """
    print("\n[Register Test] Waiting for Login screen to load...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    # Tap the Register/Sign Up navigation button/text
    # Usually: "Don't have an account? Register" or "Register"
    register_nav = driver.find_by_text_contains("Register")
    register_nav.click()
    
    # Verify Register screen title
    print("[Register Test] Navigated to Register. Checking title...")
    driver.find_by_text("Create Account", timeout=10)
    
    # Locate form fields (EditTexts)
    # Fields: Full Name, Email Address, Password, Age
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    assert len(edit_texts) >= 3, f"Could not find enough input fields, found {len(edit_texts)}"
    
    name_field = edit_texts[0]
    email_field = edit_texts[1]
    password_field = edit_texts[2]
    
    # Generate unique email for registration
    unique_email = f"appium_user_{int(time.time())}@test.com"
    
    print(f"[Register Test] Filling form with name: {config.TEST_NAME}, email: {unique_email}")
    name_field.clear()
    name_field.send_keys(config.TEST_NAME)
    email_field.clear()
    email_field.send_keys(unique_email)
    password_field.clear()
    password_field.send_keys(config.TEST_PASSWORD)
    
    # Age field is often the 4th EditText (if visible) or we can look for it
    if len(edit_texts) >= 4:
        age_field = edit_texts[3]
        age_field.clear()
        age_field.send_keys("25")
        
    # Gender dropdown: Let's tap on the dropdown selector (usually shows Male/Female/Other)
    # We will try to locate "Male" or click the gender selector container
    try:
        gender_dropdown = driver.find_by_text("Male")
        gender_dropdown.click()
        time.sleep(1)
        # Select Male/Female from the popup list
        female_option = driver.find_by_text("Female")
        female_option.click()
        print("[Register Test] Selected gender: Female")
    except Exception:
        print("[Register Test] Gender option dropdown not found/interactive, skipping dropdown step...")

    # Submit registration
    create_button = driver.find_by_text("Create Account")
    create_button.click()
    
    print("[Register Test] Submitted registration, waiting for Home screen...")
    # Verify redirect either to Home or Login
    home_welcome = driver.find_by_text_contains("Hello", timeout=15)
    assert home_welcome is not None, "Failed to reach Home dashboard after registration"
    print("[Register Test] Registration flow completed successfully.")
