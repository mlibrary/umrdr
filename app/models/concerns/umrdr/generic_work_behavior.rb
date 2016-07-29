module Umrdr
  module GenericWorkBehavior
    extend ActiveSupport::Concern

    included do
      self.human_readable_type = 'Work'
    end

    # Dirty dirty trick to ensure all have 'open' visibility.
    # Can leave all the rest of the Sufia machinery in place.
    def visibility=(value)
     super('open')
    end

  end
end
