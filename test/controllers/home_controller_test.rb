require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "visitor sees sign in and registration links" do
    get root_path

    assert_response :success
    assert_select "a", "Sign in"
    assert_select "a", "Create account"
    assert_select "button", count: 0
  end

  test "signed in user sees their identity and sign out control" do
    sign_in_as users(:registered_reader)

    get root_path

    assert_response :success
    assert_select "p", "Signed in as reader@example.com"
    assert_select "button", "Sign out"
  end
end
