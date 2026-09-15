class Comments::UpvotesController < ApplicationController
  before_action :set_post
  before_action :set_comment

  def create
    @comment.upvotes.create_or_find_by!(user: Current.user)
    redirect_back fallback_location: post_path(@post, anchor: ActionView::RecordIdentifier.dom_id(@comment)), status: :see_other
  end

  def destroy
    Current.user.upvotes.find_by(voteable: @comment)&.destroy!
    redirect_back fallback_location: post_path(@post, anchor: ActionView::RecordIdentifier.dom_id(@comment)), status: :see_other
  end

  private
    def set_post
      @post = Post.find(params.expect(:post_id))
    end

    def set_comment
      @comment = @post.comments.find(params.expect(:comment_id))
    end
end
