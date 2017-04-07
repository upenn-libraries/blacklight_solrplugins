
require "blacklight"

# MUST eager load engine or Rails won't initialize it properly
require 'blacklight_solrplugins/engine'

require "blacklight_solrplugins/util"

module BlacklightSolrplugins
  # It's important to autoload everything that uses Blacklight modules/classes,
  # b/c Blacklight also autoloads. This means that if we don't do this,
  # we get errors about undefined Blacklight modules and classes.
  autoload :Indexer, 'blacklight_solrplugins/indexer'
  autoload :FacetField, 'blacklight_solrplugins/facet_field'
  autoload :FacetFieldWindow, 'blacklight_solrplugins/facet_field_window'
  autoload :FacetFieldsQueryFilter, 'blacklight_solrplugins/facet_fields_query_filter'
  autoload :FacetItem, 'blacklight_solrplugins/facet_item'
  autoload :Response, 'blacklight_solrplugins/response'
  autoload :ResponseFacets, 'blacklight_solrplugins/response_facets'
  autoload :Routes, 'blacklight_solrplugins/routes'
end
