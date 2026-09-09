require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "database prevents a user from voting for the same post twice" do
    vote = Vote.new(user: users(:alex), votable: posts(:neighborhood))

    assert_raises(ActiveRecord::RecordNotUnique) { vote.save!(validate: false) }
  end

  test "updates the votable vote counter" do
    post = posts(:quiet_note)

    assert_difference -> { post.reload.votes_count }, 1 do
      Vote.create!(user: users(:alex), votable: post)
    end
  end
end
