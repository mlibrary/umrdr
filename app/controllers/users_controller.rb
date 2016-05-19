class UsersController < ApplicationController
  include Sufia::UsersControllerBehavior

  # Patch.  Keep until Sufia 7.0 migration
  def user_params
      params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle, :googleplus_handle, :linkedin_handle, :remove_avatar, :orcid)
  end
end
