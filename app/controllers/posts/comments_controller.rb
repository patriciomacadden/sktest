class Posts::CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: %i[ show edit update destroy ]
  before_action :authorize_author, only: %i[ show edit update destroy ]

  def new
    @comment = @post.comments.new(parent: selected_parent)
    if @comment.parent&.deleted?
      redirect_to post_path(@post), alert: "This comment can no longer receive replies."
    end
  end

  def create
    attributes = comment_params(creating: true)
    @comment = @post.comments.new(body: attributes[:body], author: current_user,
      parent: selected_parent(attributes[:parent_id]))
    if @comment.publish
      redirect_to post_path(@post, comment_id: @comment.id, anchor: helpers.dom_id(@comment)), notice: "Comment posted.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @comment.revise_by(current_user, comment_params[:body])
      redirect_to post_path(@post, comment_id: @comment.id, anchor: helpers.dom_id(@comment)), notice: "Comment updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.delete_by(current_user)
      redirect_to post_path(@post, comment_id: @comment.id, anchor: helpers.dom_id(@comment)), notice: "Comment deleted.", status: :see_other
    else
      redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence, status: :see_other
    end
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = @post.comments.find(params[:id])
    end

    def authorize_author
      head :forbidden unless @comment.editable_by?(current_user)
    end

    def selected_parent(id = params[:parent_id])
      @post.comments.find(id) if id.present?
    end

    def comment_params(creating: false)
      allowed = creating ? %w[body parent_id] : %w[body]
      supplied = params.require(:comment)
      raise ActionController::BadRequest, "Unexpected comment attributes" if (supplied.keys - allowed).any?
      params.expect(comment: allowed.map(&:to_sym))
    end
end
