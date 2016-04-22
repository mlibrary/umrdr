class ExtraInput < SimpleForm::Inputs::StringInput
  # This method only create a basic input without reading any value from object
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.text_field_tag(attribute_name, nil, merged_input_options)
  end
end
