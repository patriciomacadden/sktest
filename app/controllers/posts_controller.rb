class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @posts, @page, @has_next_page = Post.paginated(page: params[:page], posts: Post.ranked_by_votes.includes(:votes))
  end

  def show
    @post = Post.includes(:votes).find(params[:id])
  end
end
