require "test_helper"
require "timeout"

class CommentConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @author = users(:registered_member)
    @post = Post.create!(author: @author, title: "Concurrency probe")
    @root = @post.comments.create!(author: @author, body: "Root")
  end

  teardown { @post&.destroy! }

  test "deletion commits before waiting reply and reply is rejected" do
    reply = @post.comments.new(author: @author, parent: @root, body: "Late reply")
    first, second = contend(
      -> { Comment.find(@root.id).delete_by(@author) },
      -> { reply.publish }
    )
    assert first
    assert_not second
    assert_not reply.persisted?
    assert @root.reload.deleted?
  end

  test "reply commits before waiting deletion and is kept intact" do
    reply = @post.comments.new(author: @author, parent: @root, body: "Earlier reply")
    first, second = contend(
      -> { reply.publish },
      -> { Comment.find(@root.id).delete_by(@author) }
    )
    assert first
    assert second
    assert_equal "Earlier reply", reply.reload.body
    assert @root.reload.deleted?
  end

  test "deletion before waiting edit retains original text" do
    first, second = contend(
      -> { Comment.find(@root.id).delete_by(@author) },
      -> { @root.revise_by(@author, "Late edit") }
    )
    assert first
    assert_not second
    assert_equal "Root", @root.reload.body
  end

  test "database rejects a cross-post parent at transaction commit" do
    other_post = posts(:other_author_post)
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Comment.transaction do
        Comment.insert_all!([ { post_id: other_post.id, author_id: @author.id,
          parent_id: @root.id, body: "Invalid", created_at: Time.current, updated_at: Time.current } ])
      end
    end
  end

  private
    def contend(first_operation, second_operation)
      first_ready = Queue.new
      release_first = Queue.new
      second_attempted = Queue.new
      workers = []
      workers << Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          Comment.transaction do
            result = first_operation.call
            first_ready << true
            release_first.pop
            result
          end
        end
      end
      Timeout.timeout(10) { first_ready.pop }
      workers << Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          original_begin = connection.method(:begin_db_transaction)
          connection.define_singleton_method(:begin_db_transaction) do
            second_attempted << true
            original_begin.call
          end
          begin
            second_operation.call
          ensure
            connection.singleton_class.remove_method(:begin_db_transaction)
          end
        end
      end
      Timeout.timeout(10) { second_attempted.pop }
      release_first << true
      Timeout.timeout(10) { workers.map(&:value) }
    ensure
      release_first << true
      workers.each do |worker|
        worker.join(10)
        worker.kill if worker.alive?
      end
    end
end
