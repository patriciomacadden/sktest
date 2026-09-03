class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]

  def index
    @posts, @page, @has_next_page = Post.paginated(page: params[:page])
  end

  def show
    @post = Post.find(params[:id])
  end
end
