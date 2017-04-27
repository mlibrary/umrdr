# Patch RightsService to only return active terms from select_options,
# but still allow resolving the inactive terms for legacy support.
module RightsService
  def self.select_active_options
  	["klfklsf"]
    #active_elements.map{ |e| [e[:label], e[:id]] }
  end

  def self.select_all_options
  	["sdkjfklsdjfl"]
    #authority.all.select{ |e| authority.find(e[:id])[:active] }
  end
end