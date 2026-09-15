require "test_helper"

class Posts::UpvotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @reader = users(:registered_reader)
    @other_author = users(:other_author)
    @post = posts(:earlier_note)
  end

  test "authenticated user upvotes a post" do
    sign_in_as @reader

    assert_difference "Upvote.count", 1 do
      post post_upvote_path(@post)
    end

    assert_redirected_to post_path(@post)
    assert_equal @reader, @post.upvotes.last.user
    assert_equal 1, @post.reload.upvotes_count
  end

  test "upvoting an already upvoted post does not duplicate it" do
    sign_in_as @reader
    post = posts(:latest_release)

    assert_no_difference "Upvote.count" do
      post post_upvote_path(post)
    end

    assert_equal 2, post.reload.upvotes_count
  end

  test "user removes only their own post upvote" do
    sign_in_as @reader
    post = posts(:latest_release)

    assert_difference "Upvote.count", -1 do
      delete post_upvote_path(post)
    end

    assert_equal 1, post.reload.upvotes_count
    assert Upvote.exists?(user: @other_author, voteable: post)
  end

  test "unauthenticated visitors cannot change post upvotes" do
    assert_no_difference "Upvote.count" do
      post post_upvote_path(@post)
      assert_redirected_to new_session_path

      delete post_upvote_path(@post)
      assert_redirected_to new_session_path
    end
  end
end
