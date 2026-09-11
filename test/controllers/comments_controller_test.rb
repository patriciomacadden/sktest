require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = users(:published_author)
    @other_author = users(:other_author)
    @post = posts(:latest_release)
  end

  test "authenticated user creates a top-level comment" do
    sign_in_as @author

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: { comment: { body: "A new comment" } }
    end

    assert_redirected_to post_path(@post)
    comment = Comment.order(:created_at).last
    assert_equal @post, comment.post
    assert_equal @author, comment.author
    assert_nil comment.parent
    assert_equal 5, @post.reload.comments_count
  end

  test "authenticated user creates replies at multiple depths" do
    sign_in_as @other_author

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: { comment: { body: "A nested reply", parent_id: comments(:active_reply).id } }
    end

    assert_redirected_to post_path(@post)
    assert_equal comments(:active_reply), Comment.order(:created_at).last.parent
  end

  test "blank body retains input and identifies the body field" do
    sign_in_as @author

    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: { comment: { body: "" } }
    end

    assert_response :unprocessable_content
    assert_select "#new_comment_body_error", /Body can't be blank/
  end

  test "unauthenticated visitors cannot create or delete comments" do
    post post_comments_path(@post), params: { comment: { body: "A comment" } }
    assert_redirected_to new_session_path

    delete post_comment_path(@post, comments(:active_root))
    assert_redirected_to new_session_path
  end

  test "author soft-deletes their comment and retains replies" do
    sign_in_as @author
    comment = comments(:active_root)
    reply = comments(:active_reply)

    assert_no_difference "Comment.count" do
      delete post_comment_path(@post, comment)
    end

    assert_redirected_to post_path(@post)
    assert comment.reload.deleted?
    assert_equal "First comment.", comment.body
    assert_equal comment, reply.reload.parent
    assert_equal 4, @post.reload.comments_count
  end

  test "non-author cannot delete a comment" do
    sign_in_as @other_author
    comment = comments(:active_root)

    delete post_comment_path(@post, comment)

    assert_response :forbidden
    assert_not comment.reload.deleted?
  end

  test "deleted and cross-post parents reject direct reply requests" do
    sign_in_as @other_author

    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: { comment: { body: "Blocked reply", parent_id: comments(:deleted_root).id } }
    end
    assert_response :unprocessable_content
    assert_select "p", /Parent cannot accept replies/

    assert_no_difference "Comment.count" do
      post post_comments_path(posts(:earlier_note)), params: { comment: { body: "Wrong post", parent_id: comments(:active_root).id } }
    end
    assert_response :unprocessable_content
    assert_select "p", /Parent must belong to the same post/
  end
end
