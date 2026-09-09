class Comments::VotesController < ApplicationController
  before_action :set_comment

  def create
    Current.user.votes.find_or_create_by!(votable: @comment)
    redirect_to @comment.post, anchor: "comment-#{@comment.id}", notice: "Upvoted."
  rescue ActiveRecord::RecordNotUnique
    redirect_to @comment.post, anchor: "comment-#{@comment.id}"
  end

  def destroy
    Current.user.votes.find_by!(votable: @comment).destroy!
    redirect_to @comment.post, anchor: "comment-#{@comment.id}", notice: "Upvote removed."
  end

  private
    def set_comment
      @comment = Comment.find(params[:comment_id])
    end
end
