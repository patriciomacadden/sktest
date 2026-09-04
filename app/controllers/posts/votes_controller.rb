class Posts::VotesController < ApplicationController
  before_action :set_post

  def create
    current_user.votes.create!(post: @post)
    redirect_back_or_to post_path(@post), notice: "Vote added.", status: :see_other
  rescue ActiveRecord::RecordNotUnique
    redirect_back_or_to post_path(@post), alert: "You have already voted.", status: :see_other
  end

  def destroy
    current_user.votes.find_by!(post: @post).destroy!
    redirect_back_or_to post_path(@post), notice: "Vote removed.", status: :see_other
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end
end
