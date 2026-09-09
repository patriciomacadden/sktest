require "test_helper"

class PublicPostsTest < ActionDispatch::IntegrationTest
  test "visitors can browse ranked posts and public discussion" do
    get root_path

    assert_response :success
    assert_select "a", text: posts(:neighborhood).title
    assert_select "a", text: posts(:quiet_note).title

    get post_path(posts(:neighborhood))

    assert_response :success
    assert_select "a[href='https://example.com/neighborhood-rituals']:not([target])", 1
    assert_select ".comment-body", text: comments(:alex_observation).body
    assert_select ".comment-body", text: comments(:rui_reply).body
  end

  test "visitors are sent to sign in before writing" do
    get new_post_path

    assert_redirected_to new_session_path
  end
end
