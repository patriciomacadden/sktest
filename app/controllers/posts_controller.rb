class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @posts, @page, @has_next_page = Post.paginated(page: params[:page], posts: Post.ranked_by_votes)
    @voted_post_ids = current_user ? current_user.votes.where(post: @posts).pluck(:post_id) : []
  end

  def show
    @post = Post.find(params[:id])
    @voted = current_user&.votes&.exists?(post: @post) || false
    @thread = Comment::Thread.new(@post)
    @comment = @post.comments.new
  end
end
