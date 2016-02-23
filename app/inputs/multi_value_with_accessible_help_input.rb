class MultiValueWithAccessibleHelpInput < MultiValueInput
  include WithAccessibleHelp

  def html_options_for(namespace, css_classes)
    html_options = super
    if namespace == :label
      data_label = translate_from_namespace(:add_remove_labels) || raw_label_text.singularize
      html_options[:data] = {} unless html_options[:data]
      html_options[:data][:label] = data_label
    end
    html_options
  end

  def outer_wrapper
    if options[:force_single]
      "#{yield}"
    else
      super
    end
  end

  def inner_wrapper
    if options[:force_single]
      "#{yield}"
    else
      super
    end
  end

  def collection
    unless @collection
      @collection = Array.wrap(object[attribute_name]).reject { |value| value.to_s.strip.blank? }
      if @collection.empty? or ! options[:force_single]
        @collection += ['']
      end
    end
    @collection
  end

  # Overriding this so that the class is correct and the javascript for multivalue will work on this.
  def input_type
    return 'single_value' if options[:force_single]
    'multi_value'.freeze
  end
end
