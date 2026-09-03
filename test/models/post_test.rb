require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires a title" do
    post = Post.new(author: users(:registered_member), title: " ")

    assert_not post.valid?
    assert_predicate post.errors[:title], :any?
  end

  test "normalizes a bare web address to HTTPS" do
    post = Post.new(author: users(:registered_member), title: "A post", url: "example.com/some-path")

    assert_predicate post, :valid?
    assert_equal "https://example.com/some-path", post.url
  end

  test "accepts HTTP and HTTPS URLs" do
    [ "http://example.com", "https://example.com" ].each do |url|
      post = Post.new(author: users(:registered_member), title: "A post", url: url)

      assert_predicate post, :valid?
    end
  end

  test "rejects a non-web URL" do
    post = Post.new(author: users(:registered_member), title: "A post", url: "mailto:member@example.com")

    assert_not post.valid?
    assert_predicate post.errors[:url], :any?
  end

  test "paginates newest first" do
    19.times do |index|
      Post.create!(author: users(:registered_member), title: "Paged post #{index}", created_at: 1.minute.from_now + index.minutes)
    end

    posts, page, has_next_page = Post.paginated(page: 1, posts: users(:registered_member).posts)

    assert_equal Post::PAGE_SIZE, posts.length
    assert_equal 1, page
    assert has_next_page
    assert_equal "Paged post 18", posts.first.title

    posts, page, has_next_page = Post.paginated(page: 2, posts: users(:registered_member).posts)

    assert_equal [ posts(:member_older_post) ], posts
    assert_equal 2, page
    assert_not has_next_page
  end
end
