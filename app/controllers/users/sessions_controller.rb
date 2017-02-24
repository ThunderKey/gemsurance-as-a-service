class Users::SessionsController < Devise::SessionsController
  def new
    if flash.empty? && Devise.omniauth_providers.count == 1
      redirect_to omniauth_authorize_path(:user, Devise.omniauth_providers.first)
    else
      super
    end
  end
end
