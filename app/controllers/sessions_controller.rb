class SessionsController < ApplicationController
  def destroy
    sign_out(:user)
    cookies.delete("cosign-" + Sufia::Engine.config.hostname)
    redirect_to Sufia::Engine.config.logout_prefix + root_url
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
end
