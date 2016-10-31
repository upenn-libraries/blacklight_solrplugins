
module BlacklightSolrplugins

  # Response subclass for handling custom facet payloads.
  class Response < Blacklight::Solr::Response
    include ResponseFacets
  end
end
