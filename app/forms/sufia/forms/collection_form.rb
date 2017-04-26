module Sufia::Forms
  class CollectionForm < Hyrax::Forms::CollectionEditForm
  	self.terms += [:isReferencedBy]
    self.terms -= [:contributor, :rights, :visibility, :representative_id, :thumbnail_id, :identifier, :based_near, :related_url, :publisher, :date_created]
  end
end
