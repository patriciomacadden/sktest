require "test_helper"

class RootPostsTest < ActionDispatch::IntegrationTest
  test "visitor sees the public feed in newest-first order with metadata" do
    get root_path

    assert_response :success
    assert_operator response.body.index("Newest post"), :<, response.body.index("Earlier post")
    assert_select "article h2", "Newest post"
    assert_select "a[href='https://example.com/newest']", "https://example.com/newest"
    assert_select "article", /By writer@example.com on/
    assert_select "a", "Sign in"
    assert_select "a", "Create account"
    assert_select "button", count: 0
  end

  test "visitor sees an invitation when there are no posts" do
    Post.destroy_all

    get root_path

    assert_response :success
    assert_select "p", /There are no posts yet. Sign in to create the first post/
  end

  test "post bodies are rendered as text rather than HTML" do
    posts(:latest_release).update!(body: "<script>alert('unsafe')</script>\nSecond line")

    get root_path

    assert_response :success
    assert_select "script", text: /alert\('unsafe'\)/, count: 0
    assert_includes response.body, "&lt;script&gt;alert"
    assert_select "br"
  end
end
