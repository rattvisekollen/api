class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  after_action :set_access_control_headers!

  def set_access_control_headers!
    headers['Access-Control-Allow-Origin'] = request.headers["origin"]
    headers['Access-Control-Allow-Credentials'] = "true"
    headers['Access-Control-Request-Method'] = %w{GET POST PUT PATCH DELETE OPTIONS}.join(",")
  end
end
