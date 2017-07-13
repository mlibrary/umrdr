module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior

  def link_to_profile(login)
    user = ::User.find_by_user_key(login)
    return login if user.nil?

    text = if user.respond_to? :name
             user.name
           else
             login
           end

    href = profile_path(user)

    # TODO: Fix the link to the user profiles when the sufia object isn't available.
    link_to text, href
  end
  # Sufia upstream method has changed
  #def link_to_field(fieldname, fieldvalue, displayvalue = nil)
  #  p = { search_field: fieldname, q: '"' + fieldvalue + '"' }
  #  link_url = main_app.search_catalog_path(p)
  #  display = displayvalue.blank? ? fieldvalue : displayvalue
  #  link_to(display, link_url)
  #end

  def t_uri(key, scope: [])
    new_scope = scope.collect do |arg|
      if arg.is_a?(String)
        arg.gsub('.', '_')
      else
        arg
      end
    end
    I18n.t(key, scope: new_scope)
  end

  # Overrides AbilityHelper.render_visibility_link to fix bug reported in
  # UMRDR issue 727: Link provided by render_visibility_link method had 
  # path that displays a form to edit all attributes for a document. New
  # method simply renders the visibility_badge for the document.
  def render_visibility_link(document)
    visibility_badge(document.visibility)
  end

end
