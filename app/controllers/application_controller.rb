class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ExceptionHandler

  before_action :authenticate

  def authenticate
    authenticate_or_request_with_http_token do |token, options|
      token = token.gsub(/^(Bearer|Token)\s+/i, "")
      ActiveSupport::SecurityUtils.secure_compare(token, ENV["API_TOKEN"])
    end
  end
end
