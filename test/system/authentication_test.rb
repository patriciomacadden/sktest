require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "visitor signs up and signs out" do
    visit new_registration_path
    assert_selector ".app-shell--registration input.app-primary-action[value='Sign up']", count: 1
    click_on "Sign up"

    fill_in "Email address", with: "new-#{SecureRandom.uuid}@example.com"
    fill_in "Password", with: "password"
    fill_in "Confirm password", with: "password"
    click_on "Sign up"

    assert_selector "ol[aria-label='Public posts']"
    click_on "Sign out"

    assert_selector "ol[aria-label='Public posts']"
    assert_link "Sign in"
    assert_selector ".app-shell--posts-index .post-navigation__primary-action", count: 1
  end

  test "registered member signs in from the public posts homepage and reaches the password-reset form" do
    visit root_path
    click_on "Sign in"

    fill_in "Email address", with: users(:registered_member).email_address
    fill_in "Password", with: "password"
    click_on "Sign in"

    assert_selector "ol[aria-label='Public posts']"
    click_on "Sign out"
    click_on "Sign in"
    click_on "Reset password"

    assert_text "Reset password"
    assert_field "Email address", type: "email"
    assert_selector ".app-shell--password-reset input.app-primary-action[value='Email reset instructions']", count: 1
  end
end
