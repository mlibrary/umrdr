module Umrdr
  class DoiMintingService
    attr :work

    def self.mint_doi_for(work)
      Umrdr::DoiMintingService.new(work).run
    end

    def initialize(work)
      @work = work
    end

    def run
      return unless doi_server_reachable?
      work.doi = mint_doi
      work.save
      work.doi
    end

    private

    # Check that the server is reachable
    def doi_server_reachable?
      # Invoke the API and get response
      true
    end

    def generate_metadata
      Ezid::Metadata.new.tap do |md|
        md.datacite_title = work.title.first
        md.datacite_publisher = "University of Michigan"
        md.datacite_publicationyear = Date.today.year.to_s
        md.datacite_resourcetype="Dataset"
        md.datacite_creator=work.creator.join(',')
        md.target = Rails.application.routes.url_helpers.curation_concerns_generic_work_url(id: work.id)
      end
    end

    def mint_doi
      identifier = Ezid::Identifier.create(metadata: generate_metadata)
      identifier.id
    end
  end
end
