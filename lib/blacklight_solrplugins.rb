
require "blacklight"

require "blacklight_solrplugins/engine"
require "blacklight_solrplugins/facet_field"
require "blacklight_solrplugins/facet_item"
require "blacklight_solrplugins/indexer"
require "blacklight_solrplugins/response"
require "blacklight_solrplugins/routes/x_browsable"
require "blacklight_solrplugins/util"

module BlacklightSolrplugins
  # SearchState MUST be autoloaded; if you eager load it, you'll get
  # an error about Blacklight::Facet not found b/c it's a controller
  # concern that's not loaded by Rails yet, but SearchState uses it.
  # This is fixed in commit c38073a in the Blacklight repo.
  autoload :SearchState, 'blacklight_solrplugins/search_state'
end
