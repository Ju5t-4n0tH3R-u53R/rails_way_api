class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  def authenticate_with_api_key!
    return render json: { error: 'Unauthorized' }, status: :unauthorized unless session[:user_id].present?

    authenticate_or_request_with_http_token do |token, _options|
      user = User.find_by(auth_token: token)

      ActiveSupport::SecurityUtils.secure_compare(token, user.auth_token)

      user if user.present?
    end
  end
end
