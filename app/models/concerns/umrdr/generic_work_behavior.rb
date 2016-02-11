module Umrdr
  module GenericWorkBehavior
    extend ActiveSupport::Concern

    # Override constructor
    # Set resource_type to dataset
    def initialize(attributes_or_id = nil, &_block)
      super
      self.resource_type = ['Dataset']
    end

    # Dirty dirty trick to ensure all have 'open' visibility.
    # Can leave all the rest of the Sufia machinery in place.
    def visibility
      'open'
    end

    def visibility=(value)
      super('open')
    end

  end
end
