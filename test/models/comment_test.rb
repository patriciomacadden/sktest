require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "comments require nonblank text but allow long plain text" do
    comment = comments(:member_question)
    [ "", " \n\t" ].each do |text|
      assert_not comment.revise_by(users(:registered_member), text)
      assert comment.errors.of_kind?(:body, :blank)
    end
    assert comment.revise_by(users(:registered_member), "x" * 100_000)
  end

  test "only authors can mutate comments and identity cannot change" do
    comment = comments(:member_question)
    assert_not comment.editable_by?(nil)
    assert_not comment.revise_by(users(:other_author), "Intrusion")
    assert_not comment.delete_by(users(:other_author))
    assert_equal "What do you think of this post?", comment.reload.body
    { author_id: users(:other_author).id, post_id: posts(:other_author_post).id,
      parent_id: comments(:member_follow_up).id }.each do |attribute, value|
      comment.reload.assign_attributes(attribute => value)
      assert_not comment.save
    end
  end

  test "parents must be other comments on the same post" do
    comment = posts(:other_author_post).comments.new(author: users(:other_author),
      body: "Reply", parent: comments(:member_question))
    assert_not comment.publish
    assert comment.errors[:parent].any?
    comment = comments(:member_question)
    comment.parent = comment
    assert_not comment.valid?
  end

  test "deletion retains text and descendants but prevents edits and direct replies" do
    comment = comments(:member_question)
    text = comment.body
    assert comment.delete_by(users(:registered_member))
    assert_equal text, comment.reload.body
    assert comment.deleted?
    assert_not comment.revise_by(users(:registered_member), "Restore")
    assert_not comment.delete_by(users(:registered_member))
    reply = comment.post.comments.new(parent: comment, author: users(:other_author), body: "Too late")
    assert_not reply.publish
    assert comments(:other_author_reply).reload
    reply.parent = comments(:other_author_reply)
    assert reply.publish
  end

  test "post deletion purges every level and retained text" do
    comments(:member_question).delete_by(users(:registered_member))
    ids = posts(:member_recent_post).comments.pluck(:id)
    posts(:member_recent_post).destroy!
    assert_empty Comment.where(id: ids)
    assert_empty Comment::Deletion.where(comment_id: ids)
  end

  test "user deletion preserves comments on surviving posts without attribution" do
    reply = comments(:other_author_reply)
    users(:other_author).destroy!
    assert_nil reply.reload.author
    assert_equal "I would like to explore this further.", reply.body
    assert_not reply.deleted?
    assert reply.post.comments.new(parent: reply, author: users(:registered_member), body: "Still here").publish
  end

  test "user deletion also purges comments on their deleted posts" do
    ids = posts(:member_recent_post).comments.pluck(:id)
    comments(:other_author_reply).delete_by(users(:other_author))
    users(:registered_member).destroy!
    assert_empty Comment.where(id: ids)
    assert_empty Comment::Deletion.where(comment_id: ids)
  end

  test "database rejects cross-post parents and self-parenting" do
    comment = comments(:other_author_reply)
    assert_raises(ActiveRecord::InvalidForeignKey) do
      comment.update_columns(post_id: posts(:other_author_post).id)
    end
    assert_raises(ActiveRecord::StatementInvalid) { comment.reload.update_columns(parent_id: comment.id) }
  end

  test "thread traversal is ordered and does not recurse or query per comment" do
    post = posts(:member_recent_post)
    assert_equal comments(:member_question, :other_author_reply, :member_follow_up).map(&:id),
      Comment::Thread.new(post).map { |comment, _depth| comment.id }
    baseline = thread_queries(post)
    parent_id = comments(:member_follow_up).id
    first_id = Comment.maximum(:id) + 1
    rows = 1_000.times.map do |index|
      id = first_id + index
      row = { id: id, post_id: post.id, author_id: users(:registered_member).id,
        parent_id: parent_id, body: "Deep reply #{index}", created_at: Time.current, updated_at: Time.current }
      parent_id = id
      row
    end
    Comment.insert_all!(rows)
    thread = Comment::Thread.new(post).to_a
    assert_equal 1_003, thread.length
    assert_equal 1_002, thread.last.last
    assert_equal baseline, thread_queries(post)
  end

  test "equal creation timestamps have a stable id tie-breaker" do
    post = posts(:member_recent_post)
    first = comments(:member_question)
    second = post.comments.create!(author: users(:other_author), body: "Another root", created_at: first.created_at)
    roots = Comment::Thread.new(post).select { |_comment, depth| depth.zero? }.map { |comment, _depth| comment.id }
    assert_equal [ first.id, second.id ].sort, roots
  end

  private
    def thread_queries(post)
      queries = []
      listener = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] if payload[:sql].start_with?("SELECT") }
      ActiveSupport::Notifications.subscribed(listener, "sql.active_record") do
        Comment::Thread.new(post).each { |comment, _depth| [ comment.author&.email_address, comment.deleted? ] }
      end
      queries.length
    end
end
