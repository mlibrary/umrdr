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
                               pacifier: nil,
                               logger: nil )
        # skip root url
        descendants = descendant_uris( ActiveFedora.fedora.base_uri,
                                       exclude_uri: true,
                                       pacifier: pacifier,
                                       logger: logger )

        batch = []

        progress_bar_controller = ProgressBar.create( total: descendants.count,
                                                      format: "%t: |%B| %p%% %e" ) if progress_bar

        descendants.each do |uri|
          logger.debug "Re-index everything ... #{uri}" unless logger.nil?
          #pacifier.pacify '.' unless pacifier.nil?

          # catch errors
          begin
            id = ActiveFedora::Base.uri_to_id(uri)
            obj = ActiveFedora::Base.find(id)
            batch << obj.to_solr
          rescue Exception => e
            pacifier.pacify '!' unless pacifier.nil?
            @logger.error "#{uri} - #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
          end

          if (batch.count % batch_size).zero?
            begin
              pacifier.pacify 's' unless pacifier.nil?
              SolrService.add(batch, softCommit: softCommit)
              batch.clear
            rescue Exception => e
              pacifier.pacify '!' unless pacifier.nil?
              @logger.error "#{uri} - #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
            end
          end

          progress_bar_controller.increment if progress_bar_controller
        end

        if batch.present?
          begin
            pacifier.pacify 's' unless pacifier.nil?
            SolrService.add(batch, softCommit: softCommit)
            batch.clear
          rescue Exception => e
            pacifier.pacify '!' unless pacifier.nil?
            @logger.error "#{uri} - #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
          end
        end

        if final_commit
          begin
            pacifier.pacify 'c' unless pacifier.nil?
            logger.debug "Solr hard commit..." unless logger.nil?
            SolrService.commit
          rescue Exception => e
            pacifier.pacify '!' unless pacifier.nil?
            @logger.error "#{uri} - #{e.class}: #{e.message} at #{e.backtrace[0]}" unless @logger.nil?
          end
        end
        logger.info "\nRe-index everything complete." unless logger.nil?
      end

      def descendant_uris( uri, exclude_uri: false, pacifier: nil, logger: nil )
        DescendantFetcher2.new( uri,
                                exclude_self: exclude_uri,
                                pacifier: pacifier,
                                logger: logger ).descendant_and_self_uris
      end
    end

  end
end
