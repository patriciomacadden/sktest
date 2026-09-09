class PasswordMailer < ApplicationMailer
  def reset(user)
    @user = user
    @token = user.password_reset_token

    mail to: user.email, subject: "Reset your Threadwell password"
  end
end
