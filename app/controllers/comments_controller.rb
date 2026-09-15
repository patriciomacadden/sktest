class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: %i[edit update destroy]
  before_action :ensure_comment_author, only: %i[edit update destroy]

  def create
    @comment = @post.comments.build(create_params.merge(author: Current.user))

    if @comment.save
      redirect_to post_path(@post), status: :see_other
    else
      load_thread
      render "posts/show", status: :unprocessable_content
    end
  end

  def edit
    load_thread
    render_comment(editing: true)
  end

  def update
    if @comment.update(update_params.merge(edited_at: Time.current))
      redirect_to post_path(@post, anchor: ActionView::RecordIdentifier.dom_id(@comment)), status: :see_other
    else
      load_thread
      render_comment(editing: true, status: :unprocessable_content)
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
      head :forbidden unless @comment.editable_by?(Current.user)
    end

    def create_params
      params.expect(comment: %i[body parent_id])
    end

    def update_params
      params.expect(comment: [ :body ])
    end

    def render_comment(editing:, status: :ok)
      render partial: "comments/comment", locals: { comment: @comment, post: @post, comments_by_parent_id: @comments_by_parent_id, upvoted_comment_ids: @upvoted_comment_ids, editing: }, status:
    end

    def load_thread
      comments = @post.comments.includes(:author).order(:created_at)
      @comments_by_parent_id = comments.group_by(&:parent_id)
      @upvoted_post_ids = Current.user.upvotes.where(voteable: @post).pluck(:voteable_id)
      @upvoted_comment_ids = Current.user.upvotes.where(voteable: comments).pluck(:voteable_id)
    end
end
