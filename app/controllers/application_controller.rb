class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :set_current_user

  helper_method :authenticated?

  private
    def set_current_user
      Current.user = User.find_by(id: session[:user_id])
    end

    def authenticated?
      Current.user.present?
    end

    def require_authentication
      return if authenticated?

      redirect_to new_session_path, alert: "Sign in to continue."
    end

    def require_owner!(record)
      head :forbidden unless record.editable_by?(Current.user)
    end
end
