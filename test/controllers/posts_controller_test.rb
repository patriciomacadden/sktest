require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author = users(:published_author)
    @other_author = users(:other_author)
    @post = posts(:latest_release)
  end

  test "authenticated author creates a post" do
    sign_in_as @author

    assert_difference "Post.count", 1 do
      post posts_path, params: { post: { title: "A new post", url: "https://example.com/new", body: "Post body" } }
    end

    assert_redirected_to root_path
    created_post = Post.order(:created_at).last
    assert_equal @author, created_post.author
    assert_equal "A new post", created_post.title
  end

  test "invalid creation retains input and identifies the invalid URL" do
    sign_in_as @author

    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "A title", url: "not a URL", body: "Post body" } }
    end

    assert_response :unprocessable_content
    assert_select "input[name='post[url]'][value='not a URL']"
    assert_select "#post_url_error", /must be an absolute HTTP or HTTPS URL/
  end

  test "blank title prevents creation and identifies the field" do
    sign_in_as @author

    assert_no_difference "Post.count" do
      post posts_path, params: { post: { title: "", url: "https://example.com", body: "Post body" } }
    end

    assert_response :unprocessable_content
    assert_select "#post_title_error", /Title can't be blank/
  end

  test "unauthenticated visitors are redirected from post management" do
    get new_post_path
    assert_redirected_to new_session_path

    post posts_path, params: { post: { title: "A title" } }
    assert_redirected_to new_session_path

    get edit_post_path(@post)
    assert_redirected_to new_session_path

    assert_no_changes -> { @post.reload.attributes } do
      patch post_path(@post), params: { post: { title: "Changed" } }
      assert_redirected_to new_session_path

      delete post_path(@post)
      assert_redirected_to new_session_path
    end
  end

  test "author can edit and delete their post" do
    sign_in_as @author

    get edit_post_path(@post)
    assert_response :success
    assert_select "input[value='Newest post']"

    patch post_path(@post), params: { post: { title: "Updated post", url: "", body: "Updated body" } }
    assert_redirected_to root_path
    assert_equal "Updated post", @post.reload.title

    assert_difference "Post.count", -1 do
      delete post_path(@post)
    end
    assert_redirected_to root_path
  end

  test "non-author cannot manage a post by direct request" do
    sign_in_as @other_author

    get edit_post_path(@post)
    assert_response :forbidden

    assert_no_changes -> { @post.reload.attributes } do
      patch post_path(@post), params: { post: { title: "Changed" } }
      assert_response :forbidden

      delete post_path(@post)
      assert_response :forbidden
    end
  end

  test "only the author sees management controls" do
    sign_in_as @other_author

    get root_path

    assert_response :success
    assert_select "a[href='#{edit_post_path(@post)}']", count: 0
    assert_select "form[action='#{post_path(@post)}']", count: 0
  end

  test "root feed links to public post details and displays its comment count" do
    get root_path

    assert_response :success
    assert_select "a[href='#{post_path(@post)}']", text: @post.title
    assert_select "p", "4 comments"
  end

  test "visitors can read a post thread including deleted comments" do
    get post_path(@post)

    assert_response :success
    assert_select "h1", @post.title
    assert_select "article##{dom_id(comments(:deleted_root))}", text: /\[deleted\]/
    assert_select "article##{dom_id(comments(:deleted_reply))}", text: /Reply beneath deleted comment/
    assert_select "a", text: "Sign in to add a comment"
  end

  test "deleting a post deletes its comments" do
    sign_in_as @author

    assert_difference "Comment.count", -4 do
      delete post_path(@post)
    end

    assert_redirected_to root_path
  end
end
