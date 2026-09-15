require "test_helper"

class Comments::UpvotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reader = users(:registered_reader)
    @post = posts(:latest_release)
    @comment = comments(:active_reply)
  end

  test "authenticated user upvotes a comment" do
    sign_in_as @reader

    assert_difference "Upvote.count", 1 do
      post post_comment_upvote_path(@post, @comment)
    end

    assert_redirected_to post_path(@post, anchor: ActionView::RecordIdentifier.dom_id(@comment))
    assert_equal @reader, @comment.upvotes.last.user
    assert_equal 1, @comment.reload.upvotes_count
  end

  test "user removes their own comment upvote" do
    sign_in_as @reader
    comment = comments(:active_root)

    assert_difference "Upvote.count", -1 do
      delete post_comment_upvote_path(@post, comment)
    end

    assert_equal 0, comment.reload.upvotes_count
  end

  test "comment upvote routes are scoped through their post" do
    sign_in_as @reader

    assert_no_difference "Upvote.count" do
      post post_comment_upvote_path(posts(:earlier_note), @comment)
    end

    assert_response :not_found
  end

  test "unauthenticated visitors cannot change comment upvotes" do
    assert_no_difference "Upvote.count" do
      post post_comment_upvote_path(@post, @comment)
      assert_redirected_to new_session_path

      delete post_comment_upvote_path(@post, @comment)
      assert_redirected_to new_session_path
    end
  end
end
