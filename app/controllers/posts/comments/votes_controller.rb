class Posts::Comments::VotesController < ApplicationController
  before_action :set_post
  before_action :set_comment

  def create
    return head :not_found unless @comment.add_vote_by(current_user)

    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), notice: "Vote added.", status: :see_other
  rescue ActiveRecord::RecordNotUnique
    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), alert: "You have already voted.", status: :see_other
  end

  def destroy
    return head :not_found unless @comment.remove_vote_by(current_user)

    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), notice: "Vote removed.", status: :see_other
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = @post.comments.find(params[:comment_id])
    end
end
