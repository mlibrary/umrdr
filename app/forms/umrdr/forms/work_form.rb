module Umrdr::Forms
  class WorkForm < Sufia::Forms::WorkForm

    self.terms += [:methodology, :date_coverage, :isReferencedBy]

    class << self
      # This determines whether the allowed parameters are single or multiple.
      # By default it delegates to the model, but we need to override for
      # 'rights' which only has a single value on the form.
      def multiple?(term)
        case term.to_s
          when 'rights'
            false
          else
            super
        end
      end

      # Overriden to cast 'rights' to an array
      def sanitize_params(form_params)
        super.tap do |params|
          params['rights'] = Array(params['rights']) if params.key?('rights')
          params['subject'] = Array(params['subject']) if params.key?('subject')
        end
      end
    end

    def rights
        @model.rights.first
    end

    # You like danger?! Because you better pass in a hash with the correct keys. 
    # Can be alleviated when form coverage attribute is:
    # `coverages: [{begin: {:year, :month, :day}, end: {:year, :month, :day}}, ... ]`
    def merge_date_coverage_attributes!(hsh)
      @attributes.merge!(hsh&.stringify_keys || {})
    end
  end
end
