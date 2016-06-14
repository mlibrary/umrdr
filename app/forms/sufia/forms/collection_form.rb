module Sufia::Forms
  class CollectionForm < CurationConcerns::Forms::CollectionEditForm
    self.terms -= [:contributor, :rights, :visibility, :representative_id, :thumbnail_id, :identifier, :based_near, :related_url, :publisher]
  end
end
