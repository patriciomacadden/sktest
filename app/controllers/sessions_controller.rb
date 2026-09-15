class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    session[:return_to_after_authenticating] = return_to if return_to
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private
    def return_to
      return if params[:return_to].blank?

      uri = URI.parse(params[:return_to])
      params[:return_to] if uri.relative? && params[:return_to].start_with?("/") && !params[:return_to].start_with?("//")
    rescue URI::InvalidURIError
      nil
    end
end
