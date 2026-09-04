require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "visitor can browse the same newest-first public posts from the root and posts URLs" do
    get root_path

    assert_response :success
    assert_select "body.app-page--posts-index"
    assert_select "ol[aria-label='Public posts']"
    assert_select "li:first-of-type a", "Member's recent post"
    assert_select "ol[aria-label='Public posts'] .app-post__body", count: 0
    assert_select "a", { text: "example.com", href: "https://example.com/recent" }

    get posts_path

    assert_response :success
    assert_select "ol[aria-label='Public posts']"
    assert_select "li:first-of-type a", "Member's recent post"

    get post_path(posts(:member_recent_post))

    assert_response :success
    assert_select "h1", /Member's recent post/
    assert_select ".app-post__body", /A recent post by the registered member\./
    assert_select ".app-post__title a", { text: "example.com", href: "https://example.com/recent" }
  end

  test "visitor can request an oversized root page safely" do
    get root_path(page: "9" * 100)

    assert_response :success
    assert_select "li:first-of-type a", "Member's recent post"
  end

  test "visitor sees working root-page navigation only when another page exists" do
    18.times do |index|
      Post.create!(author: users(:registered_member), title: "Paged post #{index}", created_at: 1.minute.from_now + index.minutes)
    end

    get root_path

    assert_response :success
    assert_select "nav[aria-label='Posts pagination'] a", "Next"
    assert_select "li", count: Post::PAGE_SIZE

    get root_path(page: 2)

    assert_response :success
    assert_select "nav[aria-label='Posts pagination'] a", { text: "Previous", count: 1 }
    assert_select "nav[aria-label='Posts pagination'] a", { text: "Next", count: 0 }
  end
end
