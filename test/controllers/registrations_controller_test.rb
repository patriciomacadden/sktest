require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path

    assert_response :success
  end

  test "create with matching passwords" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: { user: { email_address: "new@example.com", password: "password", password_confirmation: "password" } }
    end

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with mismatched passwords" do
    assert_no_difference -> { User.count } do
      post registration_path, params: { user: { email_address: "new@example.com", password: "password", password_confirmation: "different" } }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Password confirmation/
  end

  test "create with an existing email address uses a generic response" do
    post registration_path, params: { user: { email_address: users(:registered_member).email_address, password: "password", password_confirmation: "password" } }

    assert_redirected_to new_registration_path
    follow_redirect!
    assert_select "[role=alert]", "Unable to create an account. Check your details and try again."
    assert_select "body", text: /member@example\.com/, count: 0
  end
end
