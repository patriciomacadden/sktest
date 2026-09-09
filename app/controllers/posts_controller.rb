class PostsController < ApplicationController
  before_action :require_authentication, except: %i[index show]
  before_action :set_post, only: %i[show edit update destroy]
  before_action -> { require_owner!(@post) }, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:author).ranked
  end

  def show
    @comments = @post.comments.includes(:author, :votes).order(:created_at)
  end

  def new
    @post = Current.user.posts.new
  end

  def create
    @post = Current.user.posts.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post published."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post.destroy!
    redirect_to root_path, notice: "Post deleted."
  end

  private
    def set_post
      @post = Post.includes(:author, :votes).find(params[:id])
    end

    def post_params
      params.expect(post: [ :title, :url, :body ])
    end
end
