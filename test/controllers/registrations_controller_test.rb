require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path

    assert_response :success
    assert_select "h1", "Create account"
  end

  test "create with valid attributes signs in the new user" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          email_address: "new.reader@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with a duplicate email re-renders with an error" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: users(:registered_reader).email_address,
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert]", /Email address has already been taken/
  end

  test "create with a malformed email re-renders with an error" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "not-an-email",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_content
    assert_select "[role=alert]", /Email address is invalid/
  end
end
