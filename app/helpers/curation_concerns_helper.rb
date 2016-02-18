module CurationConcernsHelper
  include ::BlacklightHelper
  include CurationConcerns::MainAppHelpers

  def default_page_title
    text = controller_name.singularize.titleize
    if action_text = action_name.titleize
      if text == 'Static'
        text = action_text
      else
        text = "#{action_text} " + text
      end
    end
    construct_page_title(text)
  end

end
