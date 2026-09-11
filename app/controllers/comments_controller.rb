class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: :destroy
  before_action :ensure_comment_author, only: :destroy

  def create
    @comment = @post.comments.build(comment_params.merge(author: Current.user))

    if @comment.save
      redirect_to post_path(@post), status: :see_other
    else
      load_thread
      render "posts/show", status: :unprocessable_content
    end
  end

  def destroy
    @comment.delete!
    redirect_to post_path(@post), status: :see_other
  end

  private
    def set_post
      @post = Post.find(params.expect(:post_id))
    end

    def set_comment
      @comment = @post.comments.find(params.expect(:id))
    end

    def ensure_comment_author
      head :forbidden unless @comment.deletable_by?(Current.user)
    end

    def comment_params
      params.expect(comment: %i[body parent_id])
    end

    def load_thread
      @comments_by_parent_id = @post.comments.includes(:author).order(:created_at).group_by(&:parent_id)
    end
end
