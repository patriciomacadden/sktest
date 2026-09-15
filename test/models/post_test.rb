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

  test "newest orders posts by creation time descending" do
    assert_equal [ posts(:latest_release), posts(:earlier_note) ], Post.newest.to_a
  end

  test "hot counts only recent votes, retains zero-vote posts, and breaks ties by newest post" do
    Upvote.delete_all
    latest = posts(:latest_release)
    earlier = posts(:earlier_note)
    zero_vote_post = Post.create!(author: users(:registered_reader), title: "No recent votes")

    Upvote.create!(user: users(:registered_reader), voteable: latest)
    Upvote.create!(user: users(:registered_reader), voteable: earlier)
    Upvote.create!(user: users(:published_author), voteable: earlier)
    Upvote.create!(user: users(:other_author), voteable: earlier, created_at: 25.hours.ago)

    assert_equal [ earlier, latest, zero_vote_post ], Post.hot.to_a
  end

  test "hot breaks equal recent vote counts by newest post first" do
    Upvote.delete_all
    latest = posts(:latest_release)
    earlier = posts(:earlier_note)

    Upvote.create!(user: users(:registered_reader), voteable: latest)
    Upvote.create!(user: users(:registered_reader), voteable: earlier)

    assert_equal [ latest, earlier ], Post.hot.to_a
  end
end
