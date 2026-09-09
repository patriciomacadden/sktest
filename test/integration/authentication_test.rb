require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "a visitor can register and sign out" do
    post registration_path, params: { user: { email_address: "new@example.com", password: "password", password_confirmation: "password" } }

    assert_redirected_to root_path
    assert_equal "new@example.com", User.last.email_address

    delete session_path
    assert_redirected_to new_session_path
  end

  test "a user can sign in and reset their password" do
    sign_in_as users(:maya)

    token = users(:maya).password_reset_token
    patch password_path(token), params: { password: "new-password", password_confirmation: "new-password" }

    assert_redirected_to new_session_path
    assert users(:maya).reload.authenticate("new-password")
  end

  test "a password reset request sends an email for a registered account" do
    assert_enqueued_emails 1 do
      post passwords_path, params: { email_address: users(:maya).email_address }
    end

    assert_redirected_to new_session_path
  end

  test "password reset requests do not reveal whether an email exists" do
    post passwords_path, params: { email_address: "nobody@example.com" }

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end
end
