module BlacklightSolrplugins

  # FacetItem subclass to provide access to custom facet payload data in Solr response data
  class FacetItem < Blacklight::Solr::Response::FacetItem

    def payload
      self['payload'] || {}
    end

    # returns array of reference types in this FacetItem
    def refs
      (payload['refs'] || {}).keys || []
    end

    # returns hash of names to counts
    def ref_names_and_counts(ref_type)
      hash = (payload['refs'] || {})[ref_type]
      Hash[hash.map { |k,v| [k, v["count"]] }]
    end

  end

end
