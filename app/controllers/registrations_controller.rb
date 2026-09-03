class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)

    if @user.save
      start_new_session_for @user
      redirect_to after_authentication_url
    elsif @user.errors.of_kind?(:email_address, :taken)
      redirect_to new_registration_path, alert: "Unable to create an account. Check your details and try again.", status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_registration_path, alert: "Unable to create an account. Check your details and try again.", status: :see_other
  end

  private
    def registration_params
      params.expect(user: [ :email_address, :password, :password_confirmation ])
    end
end
