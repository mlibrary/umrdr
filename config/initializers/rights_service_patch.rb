# Patch RightsService to only return active terms from select_options,
# but still allow resolving the inactive terms for legacy support.
RightsService.module_eval do
  def self.select_options
    active_elements.map{ |e| [e[:label], e[:id]] }
  end

  def self.active_elements
    authority.all.select{ |e| authority.find(e[:id])[:active] }
  end
end
