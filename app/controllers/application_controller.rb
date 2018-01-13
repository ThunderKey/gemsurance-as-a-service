class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!

  # :nocov:
  def new_session_path(_scope)
    new_user_session_path
  end
  # :nocov:

  private

  # :nocov:
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  # :nocov:
end
