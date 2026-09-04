require "test_helper"

class VoteTest < ActiveSupport::TestCase
  test "increments and decrements a post vote total" do
    post = posts(:member_recent_post)

    assert_difference -> { post.reload.votes_count }, 1 do
      Vote.create!(user: users(:registered_member), post: post)
    end

    assert_difference -> { post.reload.votes_count }, -1 do
      post.votes.first.destroy!
    end
  end

  test "database permits only one active vote for a user and post" do
    Vote.create!(user: users(:registered_member), post: posts(:member_recent_post))

    assert_raises ActiveRecord::RecordNotUnique do
      Vote.create!(user: users(:registered_member), post: posts(:member_recent_post))
    end
  end
end
