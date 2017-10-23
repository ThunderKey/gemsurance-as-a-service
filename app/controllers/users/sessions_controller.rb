class Users::SessionsController < Devise::SessionsController
  def new
    if known_flash? && Devise.omniauth_providers.count == 1
      redirect_to omniauth_authorize_path(:user, Devise.omniauth_providers.first)
    else
      super
    end
  end

  private

  def known_flash?
    flash.empty? || flash.to_hash == {'alert' => t('devise.failure.unauthenticated')}
  end
end
