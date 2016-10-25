module BlacklightSolrplugins

  # FacetItem subclass to provide access to custom facet payloads.
  # The accessor methods handle both cross-ref and doc-centric
  # payload formats; we could create separate subclasses, but there's
  # not much gain since we can't use them generically anyway.
  class FacetItem < Blacklight::Solr::Response::FacetItem

    def initialize(*args)
      super(*args)
      self['hits'] = (payload['count'] || term_metadata['count'] || 0).to_i
    end

    def payload
      self['payload'] || {}
    end

    # available in doc-centric payloads
    def term_metadata
      payload['termMetadata'] || {}
    end

    # available in doc-centric payloads
    def docs
      payload['docs'] || {}
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
