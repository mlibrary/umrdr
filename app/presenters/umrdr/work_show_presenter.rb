
module Umrdr
  class WorkShowPresenter < ::Sufia::WorkShowPresenter

    attr_accessor :object_profile
    delegate :methodology, :date_coverage, to: :solr_document

    def initialize(solr_document, current_ability)
      super
      @object_profile = JSON.parse(solr_document['object_profile_ssm'].first || "{}", symbolize_names: true)
    end

    def doi
      @object_profile[:doi]
    end

    def hdl
      @object_profile[:hdl]
    end

    def identifiers_minted?(identifier)
      return @object_profile[identifier]
    end

    def identifiers_pending?(identifier)
      @object_profile[identifier] == GenericWork::PENDING
    end

  end
end
