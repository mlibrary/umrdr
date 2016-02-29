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

    # TODO: Fix the link to the user profiles when the sufia object isn't available.
    # TODO: Don't hard code relative paths.  Sort out the proper url helper to use here.
    #   sufia_helper_behavior uses Sufia::Engine.routes.url_helpers.profile_path(user) --- WHY?
    #   link_to text, sufia.profile_path(user) # works when sufia is available. 
    link_to text, "/data/users/#{login}"
  end

  def link_to_field(fieldname, fieldvalue, displayvalue = nil)
    p = { search_field: fieldname, q: '"' + fieldvalue + '"' }
    link_url = main_app.search_catalog_path(p)
    display = displayvalue.blank? ? fieldvalue : displayvalue
    link_to(display, link_url)
  end

end
