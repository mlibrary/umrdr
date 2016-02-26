module SufiaHelper
  include ::BlacklightHelper
  include Sufia::BlacklightOverride
  include Sufia::SufiaHelperBehavior

  def link_to_profile(login)
    user = ::User.find_by_user_key(login)
    return login if user.nil?

    text = if user.respond_to? :name
             user.name
           else
             login
           end

    # sufia_helper_behavior uses Sufia::Engine.routes.url_helpers.profile_path(user) --- WHY?
    link_to text, sufia.profile_path(user) # 
  end

end
