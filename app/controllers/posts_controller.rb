class PostsController < ApplicationController
  allow_unauthenticated_access only: :index

  before_action :set_post, only: %i[edit update destroy]
  before_action :ensure_author, only: %i[edit update destroy]

  def index
    @posts = Post.includes(:author).order(created_at: :desc)
  end

  def new
    @post = Current.user.posts.build
  end

  def create
    @post = Current.user.posts.build(post_params)

    if @post.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to root_path, status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @post.destroy!
    redirect_to root_path, status: :see_other
  end

  private
    def set_post
      @post = Post.find(params.expect(:id))
    end

    def ensure_author
      head :forbidden unless @post.editable_by?(Current.user)
    end

    def post_params
      params.expect(post: %i[title url body])
    end
end
