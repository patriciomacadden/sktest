class Posts::CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :authorize_author, only: %i[ edit update destroy ]

  def new
    @comment = @post.comments.new(parent: selected_parent)
    if @comment.parent&.deleted?
      redirect_to post_path(@post), alert: "This comment can no longer receive replies."
    else
      respond_to do |format|
        format.turbo_stream { render_discussion(nil, form_comment: @comment, reply_parent_id: @comment.parent_id, focus_comment_id: nil) }
        format.html
      end
    end
  end

  def create
    attributes = comment_params(creating: true)
    @comment = @post.comments.new(body: attributes[:body], author: current_user,
      parent: selected_parent(attributes[:parent_id]))
    if @comment.publish
      respond_to_success("Comment posted.")
    else
      respond_to_failure(:new)
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream { render_discussion(nil, form_comment: @comment, focus_comment_id: nil) }
      format.html
    end
  end

  def update
    if @comment.revise_by(current_user, comment_params[:body])
      respond_to_success("Comment updated.")
    else
      respond_to_failure(:edit)
    end
  end

  def destroy
    if @comment.delete_by(current_user)
      respond_to_success("Comment deleted.")
    else
      respond_to do |format|
        format.turbo_stream { render_discussion(@comment.errors.full_messages.to_sentence, status: :unprocessable_entity) }
        format.html { redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence, status: :see_other }
      end
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

    def respond_to_success(notice)
      respond_to do |format|
        format.turbo_stream { render_discussion(notice) }
        format.html { redirect_to post_path(@post, comment_id: @comment.id, anchor: helpers.dom_id(@comment)), notice:, status: :see_other }
      end
    end

    def respond_to_failure(template)
      respond_to do |format|
        format.turbo_stream { render_form_errors }
        format.html { render template, status: :unprocessable_entity }
      end
    end

    def render_discussion(notice, form_comment: @post.comments.new, reply_parent_id: nil, focus_comment_id: @comment&.id, status: :ok)
      @thread = Comment::Thread.new(@post)
      streams = [
        turbo_stream.update("flash_messages", partial: "shared/flash_messages", locals: { notice:, alert: nil }),
        turbo_stream.replace("comments", partial: "posts/comments/comments", locals: {
          post: @post, comment: form_comment, reply_parent_id:, thread: @thread, notice: nil, focus_comment_id:,
          voted_comment_ids: current_user ? current_user.comment_votes.where(comment: @post.comments).pluck(:comment_id) : []
        })
      ]
      render turbo_stream: streams, status:
    end

    def render_form_errors
      render turbo_stream: turbo_stream.replace(helpers.dom_id(@comment, :form), partial: "posts/comments/form", locals: {
        post: @post, comment: @comment
      }), status: :unprocessable_entity
    end
end
