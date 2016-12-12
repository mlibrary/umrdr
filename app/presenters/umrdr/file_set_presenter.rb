module Umrdr
  class FileSetPresenter < ::Sufia::FileSetPresenter

  	def parent_doi?
  		g =GenericWork.find (self.parent.id)
  		g.doi.present?
    end

  end
end
