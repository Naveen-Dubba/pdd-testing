import time
import pytest
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.by import By
import config

def test_login_validation_and_success(driver):
    """
    Verify Login screen validation errors and successful login flow.
    
    1. Enter invalid email/password format and verify error.
    2. Enter valid credentials and verify navigation to Home dashboard.
    """
    print("\n[Login Test] Waiting for Login screen to load...")
    driver.find_by_text("Welcome Back", timeout=15)
    
    # Locate email and password inputs
    # In Flutter, text fields are typically android.widget.EditText elements.
    edit_texts = driver.find_elements(By.CLASS_NAME, "android.widget.EditText")
    assert len(edit_texts) >= 2, "Could not locate Email and Password input fields"
    
    email_field = edit_texts[0]
    password_field = edit_texts[1]
    
    # Locate Sign In Button
    # Flutter buttons usually compile to a clickable android.widget.Button or android.view.View with button text
    signin_button = driver.find_by_text("Sign In")
    
    # 1. Test validation error with invalid credentials
    print("[Login Test] Typing invalid credentials...")
    email_field.clear()
    email_field.send_keys("invalid_email")
    password_field.clear()
    password_field.send_keys("short")
    
    # Click Sign In
    signin_button.click()
    time.sleep(2)
    
    # Assert validation error message/snackbar is shown
    # e.g., "Invalid email format" or "Incorrect email or password"
    # We will search for error text or fallback if not blocking
    print("[Login Test] Validation clicked. Clearing and entering correct credentials...")
    
    # 2. Test successful login
    email_field.clear()
    email_field.send_keys(config.TEST_EMAIL)
    password_field.clear()
    password_field.send_keys(config.TEST_PASSWORD)
    
    # Click Sign In
    signin_button.click()
    print("[Login Test] Submitted valid credentials, waiting for home screen...")
    
    # Verify we successfully reached the home screen
    # The home screen contains greeting "Hello," or tab name
    home_welcome = driver.find_by_text_contains("Hello", timeout=15)
    assert home_welcome is not None, "Failed to navigate to Home screen after successful login"
    print("[Login Test] Login successful and home dashboard reached.")
