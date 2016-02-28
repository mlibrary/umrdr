
module Umrdr
  class WorkShowPresenter < ::Sufia::WorkShowPresenter

    attr_accessor :object_profile

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

    def identifiers_minted?
      doi || hdl
    end

    def identifiers_pending?(identifier)
      @object_profile[identifier] == CurationConcerns::GenericWorkActor::PENDING
    end

  end
end