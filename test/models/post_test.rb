require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "belongs to its author" do
    assert_equal users(:published_author), posts(:latest_release).author
  end

  test "requires a title" do
    post = Post.new(author: users(:published_author), url: "https://example.com")

    assert_not post.valid?
    assert_includes post.errors[:title], "can't be blank"
  end

  test "allows a blank URL and absolute HTTP(S) URLs" do
    [ nil, "", "http://example.com", "https://example.com/path" ].each do |url|
      post = Post.new(author: users(:published_author), title: "A title", url:)

      assert_predicate post, :valid?
    end
  end

  test "rejects malformed or non-HTTP(S) URLs" do
    [ "example.com", "https://", "ftp://example.com" ].each do |url|
      post = Post.new(author: users(:published_author), title: "A title", url:)

      assert_not post.valid?
      assert_includes post.errors[:url], "must be an absolute HTTP or HTTPS URL"
    end
  end

  test "is editable only by its author" do
    post = posts(:latest_release)

    assert post.editable_by?(users(:published_author))
    assert_not post.editable_by?(users(:other_author))
    assert_not post.editable_by?(nil)
  end
end
