module Umrdr::Forms
  class WorkForm < Sufia::Forms::WorkForm

    self.terms += [:methodology, :date_coverage]
    delegate :date_coverage, to: :model

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

  end
end
