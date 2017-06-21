class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  include Hydra::AccessControlsEnforcement

  # Without this filter all objects show up as admin sets.
  include Hyrax::SearchFilters

end
