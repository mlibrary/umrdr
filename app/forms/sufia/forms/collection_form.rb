module Sufia::Forms
  class CollectionForm < CurationConcerns::Forms::CollectionEditForm
    # Visibility is not settable in Sufia
    self.terms -= [:visibility, :representative_id, :thumbnail_id, :identifier, :based_near]
  end
end
