class SessionsController < ApplicationController
  def destroy
    if user_signed_in?
      sso_logout
    else
      logout_now
    end
  end

  def new
    if user_signed_in?
      # redirect to where user came from (see Devise::Controllers::StoreLocation#stored_location_for)
      redirect_to stored_location_for(:user) || sufia.dashboard_index_path
    else
      # should have been redirected via mod_cosign - error out instead of going through redirect loop
      render(:status => :forbidden, :text => 'Forbidden')
    end
  end

  def logout_now
    Rails.logger.info "Logging out, hostname: #{Sufia::Engine.config.hostname}"
    sign_out(:user)
    sso_auto_logout
    redirect_to root_url
  end
end
