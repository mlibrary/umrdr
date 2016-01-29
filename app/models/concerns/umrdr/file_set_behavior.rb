module Umrdr
  module FileSetBehavior
    extend ActiveSupport::Concern

    # Dirty dirty trick to ensure all have 'open' visibility.
    # Can leave all the rest of the Sufia machinery in place.
    def visibility
      'open'
    end

  end
end
