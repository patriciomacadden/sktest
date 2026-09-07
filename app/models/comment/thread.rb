class Comment::Thread
  include Enumerable

  def initialize(post)
    @children = post.comments.oldest_first.preload(:author, :deletion).to_a.group_by(&:parent_id)
  end

  def each
    return enum_for(:each) unless block_given?

    stack = (@children[nil] || []).reverse.map { |comment| [ comment, 0 ] }
    until stack.empty?
      comment, depth = stack.pop
      yield comment, depth
      (@children[comment.id] || []).reverse_each { |child| stack.push([ child, depth + 1 ]) }
    end
  end
end
