require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "a visitor can register and sign out" do
    post registration_path, params: { user: { email: "new@example.com", password: "password", password_confirmation: "password" } }

    assert_redirected_to root_path
    assert_equal "new@example.com", User.last.email

    delete session_path
    assert_redirected_to root_path
  end

  test "a user can sign in and reset their password" do
    sign_in_as users(:maya)
    assert_redirected_to root_path

    token = users(:maya).password_reset_token
    patch password_path(token), params: { user: { password: "new-password", password_confirmation: "new-password" } }

    assert_redirected_to new_session_path
    assert users(:maya).reload.authenticate("new-password")
  end

  test "a password reset request sends an email for a registered account" do
    assert_enqueued_emails 1 do
      post passwords_path, params: { email: users(:maya).email }
    end

    assert_redirected_to new_session_path
  end

  test "password reset requests do not reveal whether an email exists" do
    post passwords_path, params: { email: "nobody@example.com" }

    assert_redirected_to new_session_path
    assert_equal "If that email is registered, a password reset link is on its way.", flash[:notice]
  end
end
