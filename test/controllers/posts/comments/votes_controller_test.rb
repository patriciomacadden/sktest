require "test_helper"

class Posts::Comments::VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:member_recent_post)
    @comment = comments(:member_question)
  end

  test "authenticated user can vote for their own comment and remove the vote" do
    sign_in_as(users(:registered_member))

    assert_difference -> { CommentVote.count }, 1 do
      post post_comment_vote_path(@post, @comment)
    end
    assert_redirected_to post_path(@post, anchor: dom_id(@comment))
    assert_equal users(:registered_member), @comment.reload.comment_votes.sole.user
    assert_equal 1, @comment.votes_count

    assert_difference -> { CommentVote.count }, -1 do
      delete post_comment_vote_path(@post, @comment)
    end
    assert_redirected_to post_path(@post, anchor: dom_id(@comment))
    assert_equal 0, @comment.reload.votes_count
  end

  test "user cannot remove another user's vote" do
    CommentVote.create!(user: users(:other_author), comment: @comment)
    sign_in_as(users(:registered_member))

    assert_no_difference -> { CommentVote.count } do
      delete post_comment_vote_path(@post, @comment)
    end
    assert_response :not_found
    assert_equal users(:other_author), @comment.reload.comment_votes.sole.user
  end

  test "mismatched post and comment cannot mutate votes" do
    sign_in_as(users(:registered_member))

    assert_no_difference -> { CommentVote.count } do
      post post_comment_vote_path(posts(:other_author_post), @comment)
    end
    assert_response :not_found
  end

  test "deleted comments retain their votes but cannot be mutated" do
    CommentVote.create!(user: users(:registered_member), comment: @comment)
    @comment.create_deletion!
    sign_in_as(users(:registered_member))

    assert_no_difference -> { CommentVote.count } do
      post post_comment_vote_path(@post, @comment)
    end
    assert_response :not_found

    assert_no_difference -> { CommentVote.count } do
      delete post_comment_vote_path(@post, @comment)
    end
    assert_response :not_found
    assert_equal 1, @comment.reload.votes_count
  end

  test "visitor is sent to sign in without creating a vote" do
    assert_no_difference -> { CommentVote.count } do
      post post_comment_vote_path(@post, @comment)
    end

    assert_redirected_to new_session_path
  end
end
