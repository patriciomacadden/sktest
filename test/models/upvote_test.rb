require "test_helper"

class UpvoteTest < ActiveSupport::TestCase
  test "belongs to a user and either a post or comment" do
    post_upvote = upvotes(:reader_likes_latest_release)
    comment_upvote = upvotes(:reader_likes_active_root)

    assert_equal users(:registered_reader), post_upvote.user
    assert_equal posts(:latest_release), post_upvote.voteable
    assert_equal comments(:active_root), comment_upvote.voteable
  end

  test "allows only one vote from a user for a target" do
    vote = upvotes(:reader_likes_latest_release)

    assert_raises ActiveRecord::RecordNotUnique do
      Upvote.create!(user: vote.user, voteable: vote.voteable)
    end
  end

  test "updates voteable counter caches" do
    post = posts(:earlier_note)
    comment = comments(:active_reply)

    assert_difference -> { post.reload.upvotes_count }, 1 do
      Upvote.create!(user: users(:registered_reader), voteable: post)
    end

    assert_difference -> { comment.reload.upvotes_count }, 1 do
      Upvote.create!(user: users(:published_author), voteable: comment)
    end
  end

  test "is removed when its user or voteable is destroyed" do
    post_vote = upvotes(:reader_likes_latest_release)
    user_vote = Upvote.create!(user: users(:registered_reader), voteable: posts(:earlier_note))

    posts(:latest_release).destroy!
    assert_not Upvote.exists?(post_vote.id)

    users(:registered_reader).destroy!
    assert_not Upvote.exists?(user_vote.id)
  end
end
