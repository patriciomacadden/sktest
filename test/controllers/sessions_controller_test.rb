require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:registered_member) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create returns a visitor to the post they were voting on" do
    get new_session_path(return_to: post_path(posts(:member_recent_post)))

    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to post_path(posts(:member_recent_post))
  end

  test "create ignores an external return location" do
    get new_session_path(return_to: "https://example.test/phishing")

    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as(users(:registered_member))

    delete session_path

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end
end
