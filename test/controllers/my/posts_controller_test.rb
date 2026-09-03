require "test_helper"

class My::PostsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get my_posts_path

    assert_redirected_to new_session_path
  end

  test "lists only the signed-in author's posts with management actions" do
    sign_in_as(users(:registered_member))

    get my_posts_path

    assert_response :success
    assert_select "h1", "My posts"
    assert_select "article", text: /Member's recent post/
    assert_select "article", text: /Other author's post/, count: 0
    assert_select "a", { text: "Edit post", count: 2 }
    assert_select "form button", { text: "Delete post", count: 2 }
  end

  test "handles an oversized page safely" do
    sign_in_as(users(:registered_member))

    get my_posts_path(page: "9" * 100)

    assert_response :success
    assert_select "article:first-of-type a", "Member's recent post"
  end

  test "creates a post and normalizes a bare web address" do
    sign_in_as(users(:registered_member))

    assert_difference -> { Post.count }, 1 do
      post my_posts_path, params: { post: { title: "A new post", url: "www.example.com/path", body: "Post body" } }
    end

    assert_redirected_to my_posts_path
    assert_equal "https://www.example.com/path", Post.order(:id).last.url
  end

  test "renders validation errors when creation fails" do
    sign_in_as(users(:registered_member))

    post my_posts_path, params: { post: { title: "", url: "mailto:member@example.com" } }

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Title can't be blank/
    assert_select "input[name='post[url]'][value='mailto:member@example.com']"
  end

  test "updates and deletes an owned post" do
    sign_in_as(users(:registered_member))
    post = posts(:member_recent_post)

    patch my_post_path(post), params: { post: { title: "Updated post", url: "", body: "Updated body" } }

    assert_redirected_to my_posts_path
    assert_equal "Updated post", post.reload.title
    assert_nil post.url

    assert_difference -> { Post.count }, -1 do
      delete my_post_path(post)
    end

    assert_redirected_to my_posts_path
  end

  test "does not expose another author's management record" do
    sign_in_as(users(:registered_member))

    get edit_my_post_path(posts(:other_author_post))

    assert_response :not_found
  end
end
