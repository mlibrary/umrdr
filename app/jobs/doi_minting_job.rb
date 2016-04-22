class DoiMintingJob < ActiveJob::Base
  queue_as :doi_minting
  def perform(id)
    work = ActiveFedora::Base.find(id)
    user = User.find_by_user_key(work.depositor)

    # Continue only when doi is pending
    return unless work.doi.nil? || work.doi == GenericWork::PENDING

    if Umrdr::DoiMintingService.mint_doi_for work
      # do success callback
      if CurationConcerns.config.callback.set?(:after_doi_success)
        CurationConcerns.config.callback.run(:after_doi_success, work, user, log.created_at)
      end
    else
      # do failure callback
      if CurationConcerns.config.callback.set?(:after_doi_failure)
        CurationConcerns.config.callback.run(:after_doi_failure, work, user, log.created_at)
      end
    end
  end
end
