class Posts::VotesController < ApplicationController
  before_action :require_authentication
  before_action :set_post

  def create
    Current.user.votes.find_or_create_by!(votable: @post)
    redirect_to @post, notice: "Upvoted."
  rescue ActiveRecord::RecordNotUnique
    redirect_to @post
  end

  def destroy
    Current.user.votes.find_by!(votable: @post).destroy!
    redirect_to @post, notice: "Upvote removed."
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end
end
