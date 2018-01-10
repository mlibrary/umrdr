require 'tasks/active_fedora_indexing_descendent_fetcher2'

module ActiveFedora

  module Indexing
    # extend ActiveSupport::Concern
    # extend ActiveSupport::Autoload

    module ClassMethods

      # @param [Integer] batch_size - The number of Fedora objects to process for each SolrService.add call. Default 50.
      # @param [Boolean] softCommit - Do we perform a softCommit when we add the to_solr objects to SolrService. Default true.
      # @param [Boolean] progress_bar - If true output progress bar information. Default false.
      # @param [Boolean] final_commit - If true perform a hard commit to the Solr service at the completion of the batch of updates. Default false.
      def reindex_everything2( batch_size: 50,
                               softCommit: true,
                               progress_bar: false,
                               final_commit: false,
                               user_pacifier: false )
        # skip root url
        descendants = descendant_uris( ActiveFedora.fedora.base_uri, exclude_uri: true, user_pacifier: user_pacifier )

        batch = []

        progress_bar_controller = ProgressBar.create( total: descendants.count,
                                                      format: "%t: |%B| %p%% %e" ) if progress_bar

        descendants.each do |uri|
          logger.debug "Re-index everything ... #{uri}"

          batch << ActiveFedora::Base.find(ActiveFedora::Base.uri_to_id(uri)).to_solr

          if (batch.count % batch_size).zero?
            SolrService.add(batch, softCommit: softCommit)
            batch.clear
          end

          progress_bar_controller.increment if progress_bar_controller
        end

        if batch.present?
          SolrService.add(batch, softCommit: softCommit)
          batch.clear
        end

        if final_commit
          logger.debug "Solr hard commit..."
          SolrService.commit
        end
      end

      def descendant_uris( uri, exclude_uri: false, user_pacifier: false )
        DescendantFetcher2.new( uri,
                                exclude_self: exclude_uri,
                                user_pacifier: user_pacifier ).descendant_and_self_uris
      end
    end

  end
end
