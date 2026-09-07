require "test_helper"
require "timeout"

class CommentContentionTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "lock timeouts retain submitted text and report a recoverable error" do
    author = users(:registered_member)
    root = comments(:member_question)
    reply = root.post.comments.new(parent: root, author: author, body: "Keep this reply")
    operations = [ [ reply, -> { reply.publish } ],
      [ root, -> { root.revise_by(author, "Keep this edit") } ],
      [ root, -> { root.delete_by(author) } ] ]

    worker = nil
    Comment.transaction do
      Comment.where(id: root.id).update_all("body = body") # Hold a write reservation, bypassing query cache.
      operations.each do |record, operation|
        worker = Thread.new do
          ActiveRecord::Base.connection_pool.with_connection do |connection|
            connection.raw_connection.busy_timeout(1)
            begin
              operation.call
            ensure
              # Reconnect next time to restore the adapter's configured busy handler.
              connection.disconnect!
            end
          end
        end
        assert_not Timeout.timeout(10) { worker.value }
        assert_includes record.errors.full_messages, "The discussion is busy. Please try again."
      end
    end
    assert_equal "Keep this reply", reply.body
    assert_equal "Keep this edit", root.body
    assert_not reply.persisted?
    assert_equal "What do you think of this post?", root.reload.body
    assert_not root.deleted?
  ensure
    worker&.join(10)
    worker&.kill if worker&.alive?
  end
end
