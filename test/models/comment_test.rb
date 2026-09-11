require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "belongs to its post, author, and optional parent" do
    comment = comments(:active_reply)

    assert_equal posts(:latest_release), comment.post
    assert_equal users(:other_author), comment.author
    assert_equal comments(:active_root), comment.parent
  end

  test "requires a body" do
    comment = Comment.new(post: posts(:latest_release), author: users(:published_author), body: "")

    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "requires a parent from the same post" do
    comment = Comment.new(post: posts(:earlier_note), author: users(:published_author), parent: comments(:active_root), body: "Reply")

    assert_not comment.valid?
    assert_includes comment.errors[:parent], "must belong to the same post"
  end

  test "cannot reply to a deleted comment" do
    comment = Comment.new(post: posts(:latest_release), author: users(:other_author), parent: comments(:deleted_root), body: "Reply")

    assert_not comment.valid?
    assert_includes comment.errors[:parent], "cannot accept replies"
  end

  test "only an active comment author can delete it" do
    comment = comments(:active_root)

    assert comment.deletable_by?(users(:published_author))
    assert_not comment.deletable_by?(users(:other_author))

    comment.delete!

    assert comment.deleted?
    assert_not comment.deletable_by?(users(:published_author))
  end
end
