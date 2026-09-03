require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "visitor signs up and signs out" do
    visit root_path
    click_on "Sign up"

    fill_in "Email address", with: "new@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: "password"
    click_on "Sign up"

    assert_text "Signed in as new@example.com"
    click_on "Sign out"

    assert_text "Welcome"
    assert_link "Sign up"
    assert_link "Sign in"
  end

  test "registered member signs in and reaches the password-reset form" do
    visit root_path
    click_on "Sign in"

    fill_in "Email address", with: users(:registered_member).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_text "Signed in as member@example.com"
    click_on "Sign out"
    click_on "Sign in"
    click_on "Reset password"

    assert_text "Reset password"
    assert_field "Email address", type: "email"
    assert_button "Email reset instructions"
  end
end
