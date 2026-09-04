require "test_helper"

class Posts::VotesControllerTest < ActionDispatch::IntegrationTest
  setup { @post = posts(:member_recent_post) }

  test "authenticated user can vote and remove their vote" do
    sign_in_as(users(:registered_member))

    assert_difference -> { Vote.count }, 1 do
      post post_vote_path(@post)
    end
    assert_redirected_to post_path(@post)
    assert_equal users(:registered_member), @post.reload.votes.sole.user
    assert_equal 1, @post.votes_count

    assert_difference -> { Vote.count }, -1 do
      delete post_vote_path(@post)
    end
    assert_redirected_to post_path(@post)
    assert_equal 0, @post.reload.votes_count
  end

  test "user cannot remove another user's vote" do
    Vote.create!(user: users(:other_author), post: @post)
    sign_in_as(users(:registered_member))

    assert_no_difference -> { Vote.count } do
      delete post_vote_path(@post)
    end
    assert_response :not_found
    assert_equal users(:other_author), @post.reload.votes.sole.user
  end

  test "visitor is sent to sign in without creating a vote" do
    assert_no_difference -> { Vote.count } do
      post post_vote_path(@post)
    end

    assert_redirected_to new_session_path
  end
end
