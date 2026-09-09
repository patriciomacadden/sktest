class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Signed in."
    else
      flash.now[:alert] = "Email or password was incorrect."
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Signed out."
  end
end
