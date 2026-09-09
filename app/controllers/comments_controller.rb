class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]
  before_action -> { require_owner!(@comment) }, only: %i[edit update destroy]

  def create
    @post = Post.includes(:votes).find(params[:post_id])
    @comment = @post.comments.new(comment_params.merge(author: Current.user))

    if @comment.parent_comment&.deleted?
      @comment.errors.add(:parent_comment, "cannot be replied to")
      @comments = @post.comments.includes(:author, :votes).order(:created_at)
      render "posts/show", status: :unprocessable_content
    elsif @comment.save
      redirect_to @post, anchor: "comment-#{@comment.id}", notice: "Comment added."
    else
      @comments = @post.comments.includes(:author, :votes).order(:created_at)
      render "posts/show", status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params.slice(:body))
      redirect_to @comment.post, anchor: "comment-#{@comment.id}", notice: "Comment updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @comment.delete_by!(Current.user)
    redirect_to @comment.post, anchor: "comment-#{@comment.id}", notice: "Comment deleted."
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.expect(comment: [ :body, :parent_comment_id ])
    end
end
