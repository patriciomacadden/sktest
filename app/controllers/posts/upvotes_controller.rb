class Posts::UpvotesController < ApplicationController
  before_action :set_post

  def create
    @post.upvotes.create_or_find_by!(user: Current.user)
    redirect_back fallback_location: post_path(@post), status: :see_other
  end

  def destroy
    Current.user.upvotes.find_by(voteable: @post)&.destroy!
    redirect_back fallback_location: post_path(@post), status: :see_other
  end

  private
    def set_post
      @post = Post.find(params.expect(:post_id))
    end
end
