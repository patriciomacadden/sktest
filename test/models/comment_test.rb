require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "only accepts a parent from the same post" do
    comment = posts(:quiet_note).comments.new(author: users(:maya), body: "Wrong thread", parent_comment: comments(:alex_observation))

    assert_not comment.valid?
    assert_includes comment.errors[:parent_comment], "must belong to the same post"
  end

  test "deletion retains replies and prevents new replies" do
    comment = comments(:alex_observation)

    comment.delete_by!(users(:alex))

    assert comment.deleted?
    assert_equal "[deleted]", comment.body
    assert_not comment.replyable?
    assert_equal comments(:rui_reply), comment.replies.first
  end

  test "only the author may delete a comment" do
    assert_raises(ActiveRecord::RecordNotFound) { comments(:alex_observation).delete_by!(users(:rui)) }
  end
end
