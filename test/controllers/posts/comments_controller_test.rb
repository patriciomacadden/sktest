require "test_helper"

class Posts::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:member_recent_post)
    @comment = comments(:member_question)
  end

  test "visitor reads a thread but cannot write" do
    get post_path(@post)
    assert_response :success
    assert_select "#comments", text: /What do you think/
    assert_select "#comments h2", count: 0
    assert_select "#comments a", text: "Sign in to comment"
    assert_select "#comments textarea", count: 0
    assert_no_difference -> { Comment.count } do
      post post_comments_path(@post), params: { comment: { body: "Visitor" } }
    end
    assert_redirected_to new_session_path
    patch post_comment_path(@post, @comment), params: { comment: { body: "Changed" } }
    assert_redirected_to new_session_path
    delete post_comment_path(@post, @comment)
    assert_redirected_to new_session_path
    assert_not @comment.reload.deleted?
  end

  test "authenticated reader creates roots and replies and edits their own text" do
    sign_in_as(users(:registered_member))
    [ nil, @comment.id ].each do |parent_id|
      assert_difference -> { Comment.count }, 1 do
        post post_comments_path(@post), params: { comment: { body: "New comment", parent_id: parent_id } }
      end
      created = Comment.order(:id).last
      assert_equal users(:registered_member), created.author
      parent_id ? assert_equal(parent_id, created.parent_id) : assert_nil(created.parent_id)
      assert_redirected_to post_path(@post, comment_id: created.id, anchor: "comment_#{created.id}")
    end
    original_time = @comment.created_at
    patch post_comment_path(@post, @comment), params: { comment: { body: "Edited" } }
    assert_response :see_other
    assert_equal "Edited", @comment.reload.body
    assert_equal original_time, @comment.created_at
  end

  test "Turbo Streams replace discussion and invalid form without a redirect" do
    sign_in_as(users(:registered_member))
    headers = { "ACCEPT" => "text/vnd.turbo-stream.html" }
    assert_difference -> { Comment.count }, 1 do
      post post_comments_path(@post), params: { comment: { body: "Streamed" } }, headers: headers
    end
    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_select "turbo-stream[action=replace][target=comments]"
    assert_select "turbo-stream[action=update][target=flash_messages]"
    assert_includes response.body, "Comment posted."
    assert_not_includes response.body, "comment-status"

    post post_comments_path(@post), params: { comment: { body: " " } }, headers: headers
    assert_response :unprocessable_entity
    assert_includes response.body, "target=\"form_comment\""
    assert_includes response.body, "Body can&#39;t be blank"

    patch post_comment_path(@post, @comment), params: { comment: { body: "Stream edited" } }, headers: headers
    assert_response :success
    assert_select "turbo-stream[action=replace][target=comments]"
    assert_equal "Stream edited", @comment.reload.body

    delete post_comment_path(@post, @comment), headers: headers
    assert_response :success
    assert_select "turbo-stream[action=replace][target=comments]"
    assert @comment.reload.deleted?
  end

  test "ownership and thread tampering cannot mutate data" do
    sign_in_as(users(:other_author))
    patch post_comment_path(@post, @comment), params: { comment: { body: "Intrusion" } }
    assert_response :forbidden
    delete post_comment_path(@post, @comment)
    assert_response :forbidden
    get edit_post_comment_path(@post, @comment)
    assert_response :forbidden
    sign_in_as(users(:registered_member))
    foreign_comment = comments(:other_author_reply)
    delete post_comment_path(@post, foreign_comment)
    assert_response :forbidden
    %i[author_id post_id parent_id].each do |attribute|
      patch post_comment_path(@post, @comment), params: { comment: { body: "Tampered", attribute => 123 } }
      assert_response :bad_request
    end
    post post_comments_path(@post), params: { comment: { body: "Spoofed", author_id: users(:other_author).id } }
    assert_response :bad_request
    post post_comments_path(posts(:other_author_post)), params: { comment: { body: "Cross-post", parent_id: @comment.id } }
    assert_response :not_found
    assert_equal "What do you think of this post?", @comment.reload.body
  end

  test "invalid input is retained with accessible errors" do
    sign_in_as(users(:registered_member))
    post post_comments_path(@post), params: { comment: { body: " \n " } }
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /Body can't be blank/
    assert_select "textarea[aria-invalid=true][aria-describedby*='comment-errors']"
    patch post_comment_path(@post, @comment), params: { comment: { body: " \n " } }
    assert_response :unprocessable_entity
    assert_select "textarea", text: " \n "
  end

  test "script and markdown are plain text and deletion never leaks retained text" do
    @comment.update!(body: "<script>alert('x')</script>\n**literal**")
    get post_path(@post)
    assert_select "#comment_#{@comment.id} script", count: 0
    assert_select "#comment_#{@comment.id} .comment-body" do |elements|
      assert_equal @comment.body, elements.first.content
    end
    sign_in_as(users(:registered_member))
    delete post_comment_path(@post, @comment)
    assert_response :see_other
    assert_equal "<script>alert('x')</script>\n**literal**", @comment.reload.body
    get post_path(@post)
    assert_select "#comment_#{@comment.id}" do
      assert_select "p", text: "[deleted]"
      assert_select "a", count: 0
      assert_select "time", count: 0
    end
    assert_not_includes response.body, "literal"
    assert_select "#comment_#{comments(:other_author_reply).id} a", text: "Reply"
    post post_comments_path(@post), params: { comment: { body: "Late reply", parent_id: @comment.id } }
    assert_response :unprocessable_entity
    assert_select "textarea", text: "Late reply"
    patch post_comment_path(@post, @comment), params: { comment: { body: "Restore" } }
    assert_response :forbidden
    get edit_post_comment_path(@post, @comment)
    assert_response :forbidden
    assert_not_includes response.body, "literal"
  end

  test "deleted user email is absent from surviving comments" do
    users(:other_author).destroy!
    get post_path(@post)
    assert_select "#comment_#{comments(:other_author_reply).id}", text: /\[deleted user\]/
    assert_not_includes response.body, "other@example.com"
  end

  test "empty thread invites discussion without composer disclosures" do
    sign_in_as(users(:registered_member))
    get post_path(posts(:member_older_post))
    assert_select "#comments", text: /No comments yet/
    assert_select "#comment-disclosure", count: 0
    assert_select "textarea", count: 1
    assert_select "#form_comment a", count: 0
  end

  test "comment body is filtered from request parameters" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    assert_equal "[FILTERED]", filter.filter("comment" => { "body" => "Private retained text" }).dig("comment", "body")
  end

  test "invalid or missing CSRF tokens cannot mutate comments" do
    sign_in_as(users(:registered_member))
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    assert_no_difference -> { Comment.count } do
      post post_comments_path(@post), params: { comment: { body: "No token" } }
      assert_response :unprocessable_entity
      post post_comments_path(@post), params: { comment: { body: "Bad token" }, authenticity_token: "invalid" }
      assert_response :unprocessable_entity
    end
    patch post_comment_path(@post, @comment), params: { comment: { body: "No token" } }
    assert_response :unprocessable_entity
    delete post_comment_path(@post, @comment)
    assert_response :unprocessable_entity
    assert_not @comment.reload.deleted?
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end
end
