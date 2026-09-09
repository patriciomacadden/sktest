class PasswordsController < ApplicationController
  def new
  end

  def create
    if (user = User.find_by(email: params[:email]))
      PasswordMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: "If that email is registered, a password reset link is on its way."
  end

  def edit
    @user = User.find_by_password_reset_token!(params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "That password reset link is invalid or has expired."
  end

  def update
    user = User.find_by_password_reset_token!(params[:token])

    if user.update(password_params)
      redirect_to new_session_path, notice: "Password updated. Sign in with your new password."
    else
      @user = user
      render :edit, status: :unprocessable_content
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_path, alert: "That password reset link is invalid or has expired."
  end

  private
    def password_params
      params.expect(user: [ :password, :password_confirmation ])
    end
end
