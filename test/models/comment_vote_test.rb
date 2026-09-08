require "test_helper"

class CommentVoteTest < ActiveSupport::TestCase
  test "increments and decrements a comment vote total" do
    comment = comments(:member_question)

    assert_difference -> { comment.reload.votes_count }, 1 do
      CommentVote.create!(user: users(:registered_member), comment: comment)
    end

    assert_difference -> { comment.reload.votes_count }, -1 do
      comment.comment_votes.first.destroy!
    end
  end

  test "database permits only one active vote for a user and comment" do
    comment = comments(:member_question)
    CommentVote.create!(user: users(:registered_member), comment: comment)

    assert_raises ActiveRecord::RecordNotUnique do
      CommentVote.create!(user: users(:registered_member), comment: comment)
    end
  end

  test "comment deletion retains votes" do
    comment = comments(:member_question)
    CommentVote.create!(user: users(:registered_member), comment: comment)

    comment.create_deletion!

    assert_equal 1, comment.reload.votes_count
    assert_equal 1, comment.comment_votes.count
  end

  test "post deletion removes votes with its comments" do
    comment = comments(:member_question)
    CommentVote.create!(user: users(:registered_member), comment: comment)

    assert_difference -> { CommentVote.count }, -1 do
      comment.post.destroy!
    end
  end
end
