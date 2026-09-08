class Posts::Comments::VotesController < ApplicationController
  before_action :set_post
  before_action :set_comment
  before_action :reject_deleted_comment

  def create
    current_user.comment_votes.create!(comment: @comment)
    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), notice: "Vote added.", status: :see_other
  rescue ActiveRecord::RecordNotUnique
    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), alert: "You have already voted.", status: :see_other
  end

  def destroy
    current_user.comment_votes.find_by!(comment: @comment).destroy!
    redirect_back_or_to post_path(@post, anchor: helpers.dom_id(@comment)), notice: "Vote removed.", status: :see_other
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end

    def set_comment
      @comment = @post.comments.find(params[:comment_id])
    end

    def reject_deleted_comment
      head :not_found if @comment.deleted?
    end
end
