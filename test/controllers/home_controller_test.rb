require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "shows sign-up and sign-in actions when signed out" do
    get root_path

    assert_response :success
    assert_select "a", "Sign up"
    assert_select "a", "Sign in"
    assert_select "button", { text: "Sign out", count: 0 }
  end

  test "shows the signed-in email address and sign-out action" do
    sign_in_as(users(:registered_member))

    get root_path

    assert_response :success
    assert_select "h1", "Signed in as member@example.com"
    assert_select "button", "Sign out"
  end
end
