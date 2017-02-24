class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def keltec
    @user = User.from_omniauth(request.env['omniauth.auth'])

    sign_in_and_redirect @user
    set_flash_message(:notice, :success, kind: 'Keltec') if is_navigational_format?
  end
end
