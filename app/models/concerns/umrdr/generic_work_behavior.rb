module Umrdr
  module GenericWorkBehavior
    extend ActiveSupport::Concern

    included do
      self.human_readable_type = 'Work'
    end
    
  end
end
