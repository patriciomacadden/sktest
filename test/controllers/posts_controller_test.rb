require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can browse newest-first posts and open a post" do
    get posts_path

    assert_response :success
    assert_select "h1", "Posts"
    assert_select "article:first-of-type a", "Member's recent post"
    assert_select "article", text: /other@example\.com/

    get post_path(posts(:member_recent_post))

    assert_response :success
    assert_select "h1", "Member's recent post"
    assert_select "a", { text: "Original URL", href: "https://example.com/recent" }
  end

  test "visitor can request an oversized page safely" do
    get posts_path(page: "9" * 100)

    assert_response :success
    assert_select "article:first-of-type a", "Member's recent post"
  end

  test "visitor sees working page navigation only when another page exists" do
    18.times do |index|
      Post.create!(author: users(:registered_member), title: "Paged post #{index}", created_at: 1.minute.from_now + index.minutes)
    end

    get posts_path

    assert_response :success
    assert_select "nav[aria-label='Posts pagination'] a", "Next"
    assert_select "article", count: Post::PAGE_SIZE

    get posts_path(page: 2)

    assert_response :success
    assert_select "nav[aria-label='Posts pagination'] a", { text: "Previous", count: 1 }
    assert_select "nav[aria-label='Posts pagination'] a", { text: "Next", count: 0 }
  end
end
