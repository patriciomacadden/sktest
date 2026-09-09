require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "requires a title" do
    post = Post.new(author: users(:maya))

    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "ranks posts by votes then newest first" do
    assert_equal [ posts(:neighborhood), posts(:quiet_note) ], Post.ranked.to_a
  end

  test "only treats HTTP URLs as safe links" do
    post = posts(:neighborhood)

    assert_equal post.url, post.link_url
    post.update!(url: "javascript:alert(1)")
    assert_nil post.link_url
  end

  test "destroying a post destroys its comments and votes" do
    post = posts(:neighborhood)

    assert_difference [ "Comment.count", "Vote.count" ], -2 do
      post.destroy!
    end
  end
end
