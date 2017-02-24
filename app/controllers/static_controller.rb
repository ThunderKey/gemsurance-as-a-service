class StaticController < ApplicationController
  def main
  end

  if Rails.env.test?
    def autologin
      if !current_user
        sign_in User.find(params[:id])
      end
    end
  end
end
