# Generated via
#  `rails generate curation_concerns:work GenericWork`
module CurationConcerns
  class GenericWorkActor < CurationConcerns::BaseActor
    include ::CurationConcerns::WorkActorBehavior

    PENDING = 'pending'.freeze

    def mint_doi
      # Check that work doesn't already have a doi.
      return unless curation_concern.doi.nil?

      # Assign doi as "pending" in the meantime
      curation_concern.doi = PENDING

      # save (and re-index)
      curation_concern.save

      # Kick off job to get a doi
      DOIMintingJob.perform_later(curation_concern.id)
    end
  end
end
