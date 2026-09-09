require "test_helper"

class DiscussionTest < ActionDispatch::IntegrationTest
  test "a signed-in user can create a reply and upvote a post and comment" do
    sign_in_as users(:newcomer)
    post post_comments_path(posts(:neighborhood)), params: { comment: { body: "A useful thread.", parent_comment_id: comments(:rui_reply).id } }

    assert_redirected_to post_path(posts(:neighborhood))
    comment = Comment.find_by!(body: "A useful thread.")
    assert_equal comments(:rui_reply), comment.parent_comment

    assert_difference -> { posts(:quiet_note).reload.votes_count }, 1 do
      post post_vote_path(posts(:quiet_note))
    end
    assert_redirected_to post_path(posts(:quiet_note))

    assert_difference -> { comments(:rui_reply).reload.votes_count }, 1 do
      post comment_vote_path(comments(:rui_reply))
    end
  end

  test "a comment author can delete a comment but another user cannot" do
    sign_in_as users(:alex)
    delete comment_path(comments(:alex_observation))

    assert_redirected_to post_path(posts(:neighborhood))
    assert comments(:alex_observation).reload.deleted?
    assert_equal "[deleted]", comments(:alex_observation).body

    delete session_path
    sign_in_as users(:rui)
    delete post_path(posts(:neighborhood))

    assert_response :forbidden
  end

  test "deleted comments cannot be replied to" do
    comments(:alex_observation).delete_by!(users(:alex))
    sign_in_as users(:newcomer)

    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:neighborhood)), params: { comment: { body: "Too late", parent_comment_id: comments(:alex_observation).id } }
    end

    assert_response :unprocessable_content
  end
end
