class Umrdr::CatalogSearchBuilder < Umrdr::SearchBuilder
  # TODO: verify there's no remaining "advanced" search links that 
  # require :add_advanced_sarch_to_solr
  self.default_processor_chain += [
    :add_access_controls_to_solr_params,
    :add_advanced_parse_q_to_solr,
    # :add_advanced_search_to_solr,
    :show_works_or_works_that_contain_files
  ]
end
