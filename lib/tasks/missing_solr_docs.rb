require 'tasks/active_fedora_indexing_descendent_fetcher'

class MissingSolrdocs

  def descendant_uris( uri, exclude_uri: false, user_pacifier: false )
    ActiveFedora::Indexing::DescendantFetcher2.new( uri,
                                                    exclude_self: exclude_uri,
                                                    user_pacifier: user_pacifier ).descendant_and_self_uris
  end

  def filter_in( uri, id )
    return false if id.include? '-'
    return false if id.include? '/'
    return false if id.include? 'admin_set'
    return true
  end

  def file_set?( uri, id )
    rv = false
    begin
      fs = FileSet.find id
      rv = true unless fs.nil?
    rescue Exception => ignore
    end
    return rv
  end

  def generic_work?( uri, id )
    rv = false
    begin
      w = GenericWork.find id
      rv = true unless w.nil?
    rescue Exception => ignore
    end
    return rv
  end

  def hydra_model( doc )
    return '' if doc.nil?
    return "#{doc.hydra_model}"
  end

  def solr_doc( uri, id )
    return solr_doc_from_id( id )
  end

  def solr_doc_from_id( id )
    doc = nil
    begin
      doc = SolrDocument.find id
    rescue Blacklight::Exceptions::RecordNotFound => e2
      #puts "#{e2.class}: #{e2.message}"
    rescue Exception => e
      puts "#{e.class}: #{e.message} at #{e.backtrace[0]}"
    end
    return doc
  end

  def solr_doc_from_uri( uri )
    id = uri_to_id( uri )
    return solr_doc_from_id( id )
  end

  def uri_to_id( uri )
    ActiveFedora::Base.uri_to_id(uri)
  end

end