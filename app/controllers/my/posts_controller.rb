class My::PostsController < ApplicationController
  before_action :set_post, only: %i[ edit update destroy ]

  def index
    @posts, @page, @has_next_page = Post.paginated(page: params[:page], posts: current_user.posts)
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to my_posts_path, notice: "Post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to my_posts_path, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy!
    redirect_to my_posts_path, notice: "Post deleted.", status: :see_other
  end

  private
    def set_post
      @post = current_user.posts.find(params[:id])
    end

    def post_params
      params.expect(post: [ :title, :url, :body ])
    end
end
