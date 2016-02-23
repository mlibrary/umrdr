require 'simple_form'
SimpleForm.setup do |config|
  # config.error_notification_class = 'alert alert-danger'
  # config.button_class = 'btn btn-default'
  # config.boolean_label_class = nil

  config.label_text = lambda { |label, required, explicit_label| "#{label} #{required}" }

  config.wrappers :default, class: :input,
                            hint_class: :field_with_hint, error_class: :field_with_errors do |b|

    # Determines whether to use HTML5 (:email, :url, ...)
    # and required attributes
    b.use :html5

    # Calculates placeholders automatically from I18n
    # You can also pass a string as f.input placeholder: "Placeholder"
    b.use :placeholder

    ## Optional extensions
    # They are disabled unless you pass `f.input EXTENSION_NAME => true`
    # to the input. If so, they will retrieve the values from the model
    # if any exists. If you want to enable any of those
    # extensions by default, you can change `b.optional` to `b.use`.

    # Calculates maxlength from length validations for string inputs
    b.optional :maxlength

    # Calculates pattern from format validations for string inputs
    b.optional :pattern

    # Calculates min and max from length validations for numeric inputs
    b.optional :min_max

    # Calculates readonly automatically from readonly attributes
    b.optional :readonly

    ## Inputs
    b.use :label
    b.use :hint,  wrap_with: { tag: :span, class: :hint }
    b.use :input
    b.use :error, wrap_with: { tag: :span, class: :error }

    ## full_messages_for
    # If you want to display the full error message for the attribute, you can
    # use the component :full_error, like:
    #
    # b.use :full_error, wrap_with: { tag: :span, class: :error }
  end

  config.wrappers :vertical_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: 'control-label'
    b.wrapper tag: 'div' do |ba|
      ba.use :hint,  wrap_with: { tag: 'p', class: 'help-block' }
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: { tag: 'span', class: 'help-block' }
    end
  end

end